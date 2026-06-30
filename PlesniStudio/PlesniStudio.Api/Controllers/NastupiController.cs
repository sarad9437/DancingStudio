using DBB;
using Domen;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace PlesniStudio.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class NastupiController : ControllerBase
    {
        [HttpGet]
        public IActionResult GetAll()
        {
            try
            {
                List<Nastup> lista = Broker.Instance.PrikaziSveNastupe();
                return Ok(lista);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { greska = ex.Message });
            }
        }

        [HttpPost]
        [Authorize(Roles = "Admin")]
        public IActionResult Add([FromBody] Nastup nastup)
        {
            if (nastup?.Grupa == null || nastup.Organizator?.Osoba == null)
                return BadRequest(new { greska = "Подаци о наступу нису исправни." });
            try
            {
                int noviId = Broker.Instance.DodajNastup(nastup);
                if (noviId == -1)
                    return BadRequest(new { greska = "Наступ није додат." });
                return Ok(new { id = noviId });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { greska = ex.Message });
            }
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public IActionResult Update(int id, [FromBody] Nastup nastup)
        {
            if (nastup?.Grupa == null || nastup.Organizator?.Osoba == null)
                return BadRequest(new { greska = "Подаци о наступу нису исправни." });
            try
            {
                nastup.Id = id;
                Broker.Instance.IzmeniNastup(nastup);
                return Ok(new { poruka = "Наступ успешно измењен." });
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
                Broker.Instance.ObrisiNastup(id);
                return Ok(new { poruka = "Наступ успешно обрисан." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { greska = ex.Message });
            }
        }
    }
}
