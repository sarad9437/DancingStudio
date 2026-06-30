using DBB;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace PlesniStudio.API.Controllers
{
    [ApiController]
    [Route("api/auth")]
    public class AuthController : ControllerBase
    {
        private readonly IConfiguration _config;
        public AuthController(IConfiguration config) { _config = config; }

        [HttpPost("login")]
        public IActionResult Login([FromBody] LoginRequest req)
        {
            if (string.IsNullOrWhiteSpace(req?.Email) || string.IsNullOrWhiteSpace(req?.Lozinka))
                return BadRequest(new { greska = "Е-пошта и лозинка су обавезни." });
            try
            {
                var k = Broker.Instance.LoginKorisnik(req.Email, req.Lozinka);
                if (k == null)
                    return Unauthorized(new { greska = "Погрешна е-пошта или лозинка." });

                var token = GenerateToken(k.Email, k.Uloga, k.InstruktorId);

                return Ok(new
                {
                    token,
                    uloga        = k.Uloga,
                    ime          = k.Ime,
                    prezime      = k.Prezime,
                    email        = k.Email,
                    instruktorId = k.InstruktorId
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { greska = ex.Message });
            }
        }

        [HttpPut("profil")]
        [Authorize]
        public IActionResult UpdateProfil([FromBody] ProfilRequest req)
        {
            if (req == null)
                return BadRequest(new { greska = "Podaci nisu ispravni." });
            try
            {
                var email = User.FindFirstValue(ClaimTypes.Email);
                if (string.IsNullOrEmpty(email))
                    return Unauthorized(new { greska = "Nije moguće identifikovati korisnika." });

                string? noviHash = null;
                if (!string.IsNullOrWhiteSpace(req.NovaLozinka))
                    noviHash = BCrypt.Net.BCrypt.HashPassword(req.NovaLozinka);

                Broker.Instance.IzmeniKorisnika(email, req.Ime, req.Prezime, req.Email, noviHash);

                return Ok(new { poruka = "Профил успешно ажуриран." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { greska = ex.Message });
            }
        }

        private string GenerateToken(string email, string uloga, int? instruktorId)
        {
            var key     = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_config["Jwt:Key"]!));
            var creds   = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
            var expires = DateTime.UtcNow.AddMinutes(double.Parse(_config["Jwt:ExpiresInMinutes"] ?? "480"));

            var claims = new List<Claim>
            {
                new(ClaimTypes.Email, email),
                new(ClaimTypes.Role,  uloga),
            };
            if (instruktorId.HasValue)
                claims.Add(new("instruktorId", instruktorId.Value.ToString()));

            var token = new JwtSecurityToken(
                issuer:             _config["Jwt:Issuer"],
                audience:           _config["Jwt:Audience"],
                claims:             claims,
                expires:            expires,
                signingCredentials: creds
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }

    public class LoginRequest  { public string? Email { get; set; } public string? Lozinka { get; set; } }
    public class ProfilRequest { public string? Ime { get; set; } public string? Prezime { get; set; } public string? Email { get; set; } public string? NovaLozinka { get; set; } }
}