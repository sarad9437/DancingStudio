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
    public class UceniciController : ControllerBase
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
                var uloga = GetUloga();

                if (uloga == "Instruktor")
                {
                    int? instruktorId = GetInstruktorId();
                    if (instruktorId == null)
                        return Unauthorized(new { greska = "Није могуће идентификовати инструктора." });

                    List<Ucenik> lista = Broker.Instance.PrikaziUcenicePoInstruktoru(instruktorId.Value);
                    return Ok(lista);
                }

                List<Ucenik> svi = Broker.Instance.PrikaziSveUcenike();
                return Ok(svi);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { greska = ex.Message });
            }
        }

        [HttpPost]
        [Authorize(Roles = "Admin")]
        public IActionResult Add([FromBody] Ucenik ucenik, [FromQuery] int grupaId)
        {
            if (ucenik?.Osoba == null)
                return BadRequest(new { greska = "Подаци о ученику нису исправни." });
            if (grupaId <= 0)
                return BadRequest(new { greska = "Група није наведена." });
            try
            {
                int noviId = Broker.Instance.DodajUcenika(ucenik, grupaId);
                if (noviId == -1)
                    return BadRequest(new { greska = "Ученик није додат." });
                return Ok(new { id = noviId });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { greska = ex.Message });
            }
        }

        [HttpPut("{id}/nivo")]
        public IActionResult UpdateNivo(int id, [FromBody] PromeniNivoRequest req)
        {
            if (req?.NoviNivo == null)
                return BadRequest(new { greska = "Нови ниво није наведен." });

            var uloga = GetUloga();
            if (uloga == "Instruktor")
            {
                int? instruktorId = GetInstruktorId();
                if (instruktorId == null)
                    return Unauthorized(new { greska = "Није могуће идентификовати инструктора." });

                List<Ucenik> njegove = Broker.Instance.PrikaziUcenicePoInstruktoru(instruktorId.Value);
                bool pripada = njegove.Any(u => u.Osoba?.Id == id);
                if (!pripada)
                    return StatusCode(403, new { greska = "Немате право да мењате ниво овог ученика." });
            }

            try
            {
                Broker.Instance.IzmeniNivoUcenika(id, req.NoviNivo);
                return Ok(new { poruka = "Ниво успешно измењен." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { greska = ex.Message });
            }
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        public IActionResult Delete(int id)
        {
            try
            {
                Broker.Instance.ObrisiUcenika(id);
                return Ok(new { poruka = "Ученик успешно обрисан." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { greska = ex.Message });
            }
        }

        [HttpGet("{id}/nastupi")]
        public IActionResult BrojNastupa(int id)
        {
            try
            {
                int broj = Broker.Instance.BrojNastupaUcenika(id);
                return Ok(new { ucenikId = id, brojNastupa = broj });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { greska = ex.Message });
            }
        }
        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public IActionResult Update(int id, [FromBody] Ucenik ucenik)
        {
            if (ucenik?.Osoba == null)
                return BadRequest(new { greska = "Подаци о ученику нису исправни." });
            try
            {
                ucenik.Osoba.Id = id;
                Broker.Instance.IzmeniUcenicu(ucenik);
                return Ok(new { poruka = "Ученик успешно измењен." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { greska = ex.Message });
            }
        }
        [HttpPost("{id}/grupe")]
        [Authorize(Roles = "Admin")]
        public IActionResult DodajUGrupu(int id, [FromBody] GrupaIdRequest req)
        {
            if (req?.GrupaId <= 0)
                return BadRequest(new { greska = "Група није наведена." });
            try
            {
                Broker.Instance.DodajUcenicuUGrupu(id, req.GrupaId);
                return Ok(new { poruka = "Ученик успешно додат у групу." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { greska = ex.Message });
            }
        }

        [HttpDelete("{id}/grupe/{grupaId}")]
        [Authorize(Roles = "Admin")]
        public IActionResult IzbaciIzGrupe(int id, int grupaId)
        {
            try
            {
                Broker.Instance.IzbaciUcenicuIzGrupe(id, grupaId);
                return Ok(new { poruka = "Ученик успешно избачен из групе." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { greska = ex.Message });
            }
        }
    }

    public class PromeniNivoRequest
    {
        public string NoviNivo { get; set; }
    }
    public class GrupaIdRequest
    {
        public int GrupaId { get; set; }
    }
}