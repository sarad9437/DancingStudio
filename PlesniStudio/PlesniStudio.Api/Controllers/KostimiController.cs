using DBB;
using Domen;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace PlesniStudio.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class KostimiController : ControllerBase
    {
        [HttpGet]
        public IActionResult GetAll()
        {
            try
            {
                List<Kostim> lista = Broker.Instance.PrikaziSveKostime();
                return Ok(lista);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { greska = ex.Message });
            }
        }

        [HttpPost]
        [Authorize(Roles = "Admin")]
        public IActionResult Add([FromBody] Kostim kostim)
        {
            if (kostim == null)
                return BadRequest(new { greska = "Подаци о костиму нису исправни." });
            try
            {
                int noviId = Broker.Instance.DodajKostim(kostim);
                if (noviId == -1)
                    return BadRequest(new { greska = "Костим није додат." });
                return Ok(new { id = noviId });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { greska = ex.Message });
            }
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public IActionResult Update(int id, [FromBody] Kostim kostim)
        {
            if (kostim == null)
                return BadRequest(new { greska = "Подаци о костиму нису исправни." });
            try
            {
                kostim.Id = id;
                Broker.Instance.IzmeniKostim(kostim);
                return Ok(new { poruka = "Костим успешно измењен." });
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
                Broker.Instance.ObrisiKostim(id);
                return Ok(new { poruka = "Костим успешно обрисан." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { greska = ex.Message });
            }
        }
    }
}