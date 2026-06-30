using DBB;
using Domen;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace PlesniStudio.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = "Admin")]
    public class InstruktoriController : ControllerBase
    {
        [HttpGet]
        public IActionResult GetAll()
        {
            try
            {
                List<Instruktor> lista = Broker.Instance.PrikaziSveInstruktore();
                return Ok(lista);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { greska = ex.Message });
            }
        }

        [HttpPost]
        public IActionResult Add([FromBody] Instruktor instruktor)
        {
            if (instruktor?.Osoba == null)
                return BadRequest(new { greska = "Подаци о инструктору нису исправни." });
            try
            {
                int noviId = Broker.Instance.DodajInstruktora(instruktor);
                if (noviId == -1)
                    return BadRequest(new { greska = "Инструктор није додат." });
                return Ok(new { id = noviId });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { greska = ex.Message });
            }
        }

        [HttpPut("{id}")]
        public IActionResult Update(int id, [FromBody] Instruktor instruktor)
        {
            if (instruktor?.Osoba == null)
                return BadRequest(new { greska = "Подаци о инструктору нису исправни." });
            try
            {
                instruktor.Osoba.Id = id;
                Broker.Instance.IzmeniInstruktora(instruktor);
                return Ok(new { poruka = "Инструктор успешно измењен." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { greska = ex.Message });
            }
        }

        [HttpPut("promeni-lozinku")]
        public IActionResult ChangeLozinka([FromBody] LozinkaRequest req)
        {
            if (string.IsNullOrWhiteSpace(req?.NovaLozinka))
                return BadRequest(new { greska = "Лозинка не може бити празна." });
            if (string.IsNullOrWhiteSpace(req?.Email))
                return BadRequest(new { greska = "Емаил није наведен." });
            try
            {
                string hash = BCrypt.Net.BCrypt.HashPassword(req.NovaLozinka);
                Broker.Instance.PromeniLozinkuInstruktora(req.Email, hash);
                return Ok(new { poruka = "Лозинка успешно промењена." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { greska = ex.Message });
            }
        }

        [HttpDelete("{id}")]
        public IActionResult Delete(int id)
        {
            try
            {
                Broker.Instance.ObrisiInstruktora(id);
                return Ok(new { poruka = "Инструктор успешно обрисан." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { greska = ex.Message });
            }
        }
    }

    public class LozinkaRequest
    {
        public string NovaLozinka { get; set; }
        public string Email { get; set; }
    }
}