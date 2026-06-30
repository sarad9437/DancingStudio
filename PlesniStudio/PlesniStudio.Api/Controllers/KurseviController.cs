using DBB;
using Domen;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace PlesniStudio.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = "Admin")]
    public class KurseviController : ControllerBase
    {
        [HttpGet]
        public IActionResult GetAll()
        {
            try
            {
                List<Kurs> lista = Broker.Instance.PrikaziSveKurseve();
                return Ok(lista);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { greska = ex.Message });
            }
        }

        [HttpPost]
        public IActionResult Add([FromBody] Kurs kurs)
        {
            if (kurs == null)
                return BadRequest(new { greska = "Подаци о курсу нису исправни." });
            try
            {
                int noviId = Broker.Instance.DodajKurs(kurs);
                if (noviId == -1)
                    return BadRequest(new { greska = "Курс није додат." });
                return Ok(new { id = noviId });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { greska = ex.Message });
            }
        }

        [HttpPut("{id}")]
        public IActionResult Update(int id, [FromBody] Kurs kurs)
        {
            if (kurs == null)
                return BadRequest(new { greska = "Подаци о курсу нису исправни." });
            try
            {
                kurs.Id = id;
                Broker.Instance.IzmeniKurs(kurs);
                return Ok(new { poruka = "Курс успешно измењен." });
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
                Broker.Instance.ObrisiKurs(id);
                return Ok(new { poruka = "Курс успешно обрисан." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { greska = ex.Message });
            }
        }
    }
}
