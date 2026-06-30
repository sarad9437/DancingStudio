using DBB;
using Domen;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace PlesniStudio.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ZaduzenjaController : ControllerBase
    {
        private string? GetUloga() =>
            User.FindFirstValue(ClaimTypes.Role);

        private int? GetInstruktorId()
        {
            var val = User.FindFirstValue("instruktorId");
            if (int.TryParse(val, out int id) && id > 0) return id;
            return null;
        }

        [HttpGet]
        public IActionResult GetAll()
        {
            try
            {
                string? uloga = GetUloga();

                if (uloga == "Admin")
                {
                    List<Zaduzenje> lista = Broker.Instance.PrikaziSvaZaduzenja();
                    return Ok(lista);
                }
                else if (uloga == "Instruktor")
                {
                    int? instruktorId = GetInstruktorId();
                    if (instruktorId == null)
                        return Unauthorized(new { greska = "Није могуће идентификовати инструктора." });

                    List<Zaduzenje> lista = Broker.Instance.PrikaziZaduzenjaPoInstruktoru(instruktorId.Value);
                    return Ok(lista);
                }

                return Unauthorized();
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { greska = ex.Message });
            }
        }

        [HttpPost]
        public IActionResult Add([FromBody] Zaduzenje zaduzenje)
        {
            if (zaduzenje?.Ucenik?.Osoba == null || zaduzenje.Nastup == null || zaduzenje.Kostim == null)
                return BadRequest(new { greska = "Подаци о задужењу нису исправни." });
            try
            {
                string? uloga = GetUloga();
                if (uloga == "Instruktor")
                {
                    int? instruktorId = GetInstruktorId();
                    if (instruktorId == null) return Unauthorized();

                    List<Ucenik> njegove = Broker.Instance.PrikaziUcenicePoInstruktoru(instruktorId.Value);
                    bool pripada = njegove.Any(u => u.Osoba.Id == zaduzenje.Ucenik.Osoba.Id);
                    if (!pripada) return Forbid();
                }

                Broker.Instance.DodajZaduzenje(zaduzenje);
                return Ok(new { poruka = "Задужење успешно додато." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { greska = ex.Message });
            }
        }

        [HttpPut]
        public IActionResult Update([FromBody] IzmeniZaduzenjeRequest req)
        {
            if (req == null)
                return BadRequest(new { greska = "Подаци нису исправни." });
            try
            {
                string? uloga = GetUloga();
                if (uloga == "Instruktor")
                {
                    int? instruktorId = GetInstruktorId();
                    if (instruktorId == null) return Unauthorized();

                    List<Ucenik> njegove = Broker.Instance.PrikaziUcenicePoInstruktoru(instruktorId.Value);
                    bool pripada = njegove.Any(u => u.Osoba.Id == req.UcenikId);
                    if (!pripada) return Forbid();
                }

                Broker.Instance.IzmeniZaduzenje(req.UcenikId, req.NastupId, req.NoviKostimId);
                return Ok(new { poruka = "Задужење успешно измењено." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { greska = ex.Message });
            }
        }

        [HttpDelete]
        public IActionResult Delete([FromBody] ObrisiZaduzenjeRequest req)
        {
            if (req == null)
                return BadRequest(new { greska = "Подаци нису исправни." });
            try
            {
                string? uloga = GetUloga();
                if (uloga == "Instruktor")
                {
                    int? instruktorId = GetInstruktorId();
                    if (instruktorId == null) return Unauthorized();

                    List<Ucenik> njegove = Broker.Instance.PrikaziUcenicePoInstruktoru(instruktorId.Value);
                    bool pripada = njegove.Any(u => u.Osoba.Id == req.UcenikId);
                    if (!pripada) return Forbid();
                }

                Broker.Instance.ObrisiZaduzenje(req.UcenikId, req.NastupId);
                return Ok(new { poruka = "Задужење успешно обрисано." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { greska = ex.Message });
            }
        }
    }

    public class IzmeniZaduzenjeRequest
    {
        public int UcenikId { get; set; }
        public int NastupId { get; set; }
        public int NoviKostimId { get; set; }
    }

    public class ObrisiZaduzenjeRequest
    {
        public int UcenikId { get; set; }
        public int NastupId { get; set; }
    }
}