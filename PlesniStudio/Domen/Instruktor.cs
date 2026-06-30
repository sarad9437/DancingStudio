namespace Domen
{
    public class Instruktor
    {
        public Osoba? Osoba { get; set; }
        public string? Specijalnost { get; set; }
        public string? Sertifikat { get; set; }

        public override string ToString()
        {
            return $"{Osoba?.Ime} {Osoba?.Prezime} | Specijalnost: {Specijalnost}";
        }
    }
}
