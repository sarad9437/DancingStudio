namespace Domen
{
    public class Nastup
    {
        public int Id { get; set; }
        public string? Naziv { get; set; }
        public DateTime Datum { get; set; }
        public string? Lokacija { get; set; }
        public Grupa? Grupa { get; set; }
        public Instruktor? Organizator { get; set; }
        public string? OrganizatorIme { get; set; }
        public string? OrganizatorPrezime { get; set; }

        public override string ToString()
        {
            return $"{Id} – {Naziv} | {Datum:dd.MM.yyyy} | {Lokacija}";
        }
    }
}
