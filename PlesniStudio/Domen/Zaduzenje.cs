namespace Domen
{
    public class Zaduzenje
    {
        public Ucenik? Ucenik { get; set; }
        public Nastup? Nastup { get; set; }
        public Kostim? Kostim { get; set; }
        public DateTime DatumZaduzenja { get; set; }

        public int UcenikId { get; set; }
        public string? UcenikIme { get; set; }
        public string? UcenikPrezime { get; set; }
        public int NastupId { get; set; }
        public string? NastupNaziv { get; set; }
        public DateTime NastupDatum { get; set; }
        public int KostimId { get; set; }
        public string? KostimNaziv { get; set; }
        public string? KostimVelicina { get; set; }
        public string? KostimBoja { get; set; }

        public override string ToString()
        {
            return $"{UcenikIme} {UcenikPrezime} | {NastupNaziv} | {KostimNaziv} ({KostimVelicina})";
        }
    }
}
