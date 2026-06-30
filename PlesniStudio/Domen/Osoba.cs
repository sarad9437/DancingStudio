namespace Domen
{
    public class Osoba
    {
        public int Id { get; set; }
        public string? Ime { get; set; }
        public string? Prezime { get; set; }
        public string? Email { get; set; }

        public override string ToString()
        {
            return $"{Id} – {Ime} {Prezime} ({Email})";
        }
    }
}
