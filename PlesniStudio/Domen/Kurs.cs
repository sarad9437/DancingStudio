namespace Domen
{
    public class Kurs
    {
        public int Id { get; set; }
        public string? Naziv { get; set; }
        public string? Opis { get; set; }
        public int TrajanjeMeseci { get; set; }
        public int? PretKursId { get; set; }

        public override string ToString()
        {
            return $"{Id} – {Naziv}";
        }
    }
}
