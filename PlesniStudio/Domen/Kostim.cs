namespace Domen
{
    public class Kostim
    {
        public int Id { get; set; }
        public string? Naziv { get; set; }
        public string? Velicina { get; set; }
        public string? Boja { get; set; }

        public override string ToString()
        {
            return $"{Id} – {Naziv} | {Velicina} | {Boja}";
        }
    }
}
