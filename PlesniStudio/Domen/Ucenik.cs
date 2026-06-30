namespace Domen
{
    public class Ucenik
    {
        public Osoba? Osoba { get; set; }
        public string? BrojKnjizice { get; set; }
        public DateTime DatumUpisa { get; set; }
        public string? Nivo { get; set; }
        public string? GrupaNaziv { get; set; }

        public int GrupaId { get; set; }
        public override string ToString()
        {
            return $"{Osoba?.Ime} {Osoba?.Prezime} | Knjizica: {BrojKnjizice} | Nivo: {Nivo} | Grupa: {GrupaNaziv}";
        }
    }
}