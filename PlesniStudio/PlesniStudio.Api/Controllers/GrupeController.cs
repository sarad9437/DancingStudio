using DBB;
using Domen;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace PlesniStudio.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class GrupeController : ControllerBase
    {
        [HttpGet]
        public IActionResult GetAll()
        {
            try
            {
                List<Grupa> lista = Broker.Instance.PrikaziSveGrupe();
                return Ok(lista);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { greska = ex.Message });
            }
        }

        [HttpPost]
        [Authorize(Roles = "Admin")]
        public IActionResult Add([FromBody] Grupa grupa)
        {
            if (grupa?.Kurs == null || grupa.Koreograf?.Osoba == null || grupa.Predavac?.Osoba == null)
                return BadRequest(new { greska = "Подаци о групи нису исправни." });
            try
            {
                int noviId = Broker.Instance.DodajGrupu(grupa);
                if (noviId == -1)
                    return BadRequest(new { greska = "Група није додата." });
                return Ok(new { id = noviId });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { greska = ex.Message });
            }
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public IActionResult Update(int id, [FromBody] Grupa grupa)
        {
            if (grupa?.Kurs == null || grupa.Koreograf?.Osoba == null || grupa.Predavac?.Osoba == null)
                return BadRequest(new { greska = "Подаци о групи нису исправни." });
            try
            {
                grupa.Id = id;
                Broker.Instance.IzmeniGrupu(grupa);
                return Ok(new { poruka = "Група успешно измењена." });
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
                Broker.Instance.ObrisiGrupu(id);
                return Ok(new { poruka = "Група успешно обрисана." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { greska = ex.Message });
            }
        }
    }
}
