namespace Domen
{
    public class Grupa
    {
        public int Id { get; set; }
        public string? Naziv { get; set; }
        public Kurs? Kurs { get; set; }
        public Instruktor? Koreograf { get; set; }
        public Instruktor? Predavac { get; set; }
        public int UkupnoUcenika { get; set; }

        public override string ToString()
        {
            return $"{Id} – {Naziv} | Kurs: {Kurs?.Naziv} | Ucenika: {UkupnoUcenika}";
        }
    }
}
