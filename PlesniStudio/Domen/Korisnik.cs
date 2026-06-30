namespace Domen
{
    public class Korisnik
    {
        public int Id { get; set; }
        public string? Email { get; set; }
        public string? LozinkaHash { get; set; }
        public string? Uloga { get; set; }
        public int? InstruktorId { get; set; }
        public string? Ime { get; set; }
        public string? Prezime { get; set; }

        public override string ToString()
        {
            return $"{Id} – {Email} | {Uloga}";
        }
    }
}