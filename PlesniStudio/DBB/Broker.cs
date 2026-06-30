using Domen;
using Microsoft.Data.SqlClient;
using System.Data;

namespace DBB
{
    public class Broker
    {
        private readonly DbConnection connection;
        private static Broker instance;

        private Broker()
        {
            connection = new DbConnection();
        }

        public static Broker Instance
        {
            get
            {
                if (instance == null)
                    instance = new Broker();
                return instance;
            }
        }

        public int DodajUcenika(Ucenik ucenik, int grupaId)
        {
            try
            {
                using SqlConnection conn = connection.CreateNewConnection();
                using SqlCommand cmd = new SqlCommand("api_studio.DodajUcenika", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@ime", ucenik.Osoba.Ime);
                cmd.Parameters.AddWithValue("@prezime", ucenik.Osoba.Prezime);
                cmd.Parameters.AddWithValue("@email", ucenik.Osoba.Email);
                cmd.Parameters.AddWithValue("@datumUpisa", ucenik.DatumUpisa);
                cmd.Parameters.AddWithValue("@nivo", ucenik.Nivo);
                cmd.Parameters.AddWithValue("@grupaId", grupaId);

                SqlParameter outParam = new SqlParameter("@newId", SqlDbType.Int)
                { Direction = ParameterDirection.Output };
                cmd.Parameters.Add(outParam);

                cmd.ExecuteNonQuery();

                int noviId = (int)outParam.Value;
                ucenik.Osoba.Id = noviId;
                return noviId;
            }
            catch (SqlException ex) { throw new Exception(ex.Message); }
        }

        public void ObrisiUcenika(int ucenikId)
        {
            try
            {
                using SqlConnection conn = connection.CreateNewConnection();
                using SqlCommand cmd = new SqlCommand("api_studio.ObrisiUcenika", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ucenikId", ucenikId);
                cmd.ExecuteNonQuery();
            }
            catch (SqlException ex) { throw new Exception(ex.Message); }
        }

        public void IzmeniNivoUcenika(int ucenikId, string noviNivo)
        {
            try
            {
                using SqlConnection conn = connection.CreateNewConnection();
                using SqlCommand cmd = new SqlCommand("api_studio.IzmeniNivoUcenika", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ucenikId", ucenikId);
                cmd.Parameters.AddWithValue("@noviNivo", noviNivo);
                cmd.ExecuteNonQuery();
            }
            catch (SqlException ex) { throw new Exception(ex.Message); }
        }

        public void IzmeniUcenicu(Ucenik ucenik)
        {
            try
            {
                using SqlConnection conn = connection.CreateNewConnection();
                using SqlCommand cmd = new SqlCommand("api_studio.IzmeniUcenicu", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@ucenikId", ucenik.Osoba.Id);
                cmd.Parameters.AddWithValue("@ime", ucenik.Osoba.Ime);
                cmd.Parameters.AddWithValue("@prezime", ucenik.Osoba.Prezime);
                cmd.Parameters.AddWithValue("@email", ucenik.Osoba.Email);
                cmd.Parameters.AddWithValue("@datumUpisa", ucenik.DatumUpisa);
                cmd.Parameters.AddWithValue("@nivo", ucenik.Nivo);

                cmd.ExecuteNonQuery();
            }
            catch (SqlException ex) { throw new Exception(ex.Message); }
        }

        public int BrojNastupaUcenika(int ucenikId)
        {
            try
            {
                using SqlConnection conn = connection.CreateNewConnection();
                using SqlCommand cmd = new SqlCommand("api_studio.BrojNastupaUcenika", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ucenikId", ucenikId);

                SqlParameter outParam = new SqlParameter("@rezultat", SqlDbType.Int)
                { Direction = ParameterDirection.Output };
                cmd.Parameters.Add(outParam);
                cmd.ExecuteNonQuery();
                return (int)outParam.Value;
            }
            catch (SqlException ex) { throw new Exception(ex.Message); }
        }

        public List<Ucenik> PrikaziSveUcenike()
        {
            List<Ucenik> lista = new List<Ucenik>();
            try
            {
                using SqlConnection conn = connection.CreateNewConnection();
                using SqlCommand cmd = new SqlCommand(
                    "SELECT * FROM api_studio.UCENIK_GRUPA", conn);
                using SqlDataReader reader = cmd.ExecuteReader();
                while (reader.Read())
                    lista.Add(new Ucenik
                    {
                        Osoba = new Osoba
                        {
                            Id = (int)reader["OsobaId"],
                            Ime = (string)reader["Ime"],
                            Prezime = (string)reader["Prezime"],
                            Email = (string)reader["Email"]
                        },
                        BrojKnjizice = (string)reader["BrojKnjizice"],
                        DatumUpisa = (DateTime)reader["DatumUpisa"],
                        Nivo = (string)reader["Nivo"],
                        GrupaNaziv = (string)reader["GrupaNaziv"],
                        GrupaId = (int)reader["GrupaId"]
                    });
            }
            catch (SqlException ex) { throw new Exception(ex.Message); }
            return lista;
        }

        

        public void IzbaciUcenicuIzGrupe(int ucenikId, int grupaId)
        {
            try
            {
                using SqlConnection conn = connection.CreateNewConnection();
                using SqlCommand cmd = new SqlCommand("api_studio.IzbaciUcenicuIzGrupe", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ucenikId", ucenikId);
                cmd.Parameters.AddWithValue("@grupaId", grupaId);
                cmd.ExecuteNonQuery();
            }
            catch (SqlException ex) { throw new Exception(ex.Message); }
        }

        public void DodajUcenicuUGrupu(int ucenikId, int grupaId)
        {
            try
            {
                using SqlConnection conn = connection.CreateNewConnection();
                using SqlCommand cmd = new SqlCommand("api_studio.DodajUcenikuUGrupu", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ucenikId", ucenikId);
                cmd.Parameters.AddWithValue("@grupaId", grupaId);
                cmd.ExecuteNonQuery();
            }
            catch (SqlException ex) { throw new Exception(ex.Message); }
        }
        public void IzmeniInstruktora(Instruktor instruktor)
        {
            try
            {
                using SqlConnection conn = connection.CreateNewConnection();
                using SqlCommand cmd = new SqlCommand("api_studio.IzmeniInstruktora", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@instruktorId", instruktor.Osoba.Id);
                cmd.Parameters.AddWithValue("@ime", instruktor.Osoba.Ime);
                cmd.Parameters.AddWithValue("@prezime", instruktor.Osoba.Prezime);
                cmd.Parameters.AddWithValue("@email", instruktor.Osoba.Email);
                cmd.Parameters.AddWithValue("@specijalnost", instruktor.Specijalnost);
                cmd.Parameters.AddWithValue("@sertifikat",
                    instruktor.Sertifikat != null
                        ? (object)instruktor.Sertifikat
                        : DBNull.Value);

                cmd.ExecuteNonQuery();
            }
            catch (SqlException ex) { throw new Exception(ex.Message); }
        }

        public void DodajUcenikuUGrupu(int ucenikId, int grupaId)
        {
            try
            {
                using SqlConnection conn = connection.CreateNewConnection();
                using SqlCommand cmd = new SqlCommand("api_studio.DodajUcenikuUGrupu", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ucenikId", ucenikId);
                cmd.Parameters.AddWithValue("@grupaId", grupaId);
                cmd.ExecuteNonQuery();
            }
            catch (SqlException ex) { throw new Exception(ex.Message); }
        }


        public int DodajInstruktora(Instruktor instruktor)
        {
            try
            {
                using SqlConnection conn = connection.CreateNewConnection();
                using SqlCommand cmd = new SqlCommand("api_studio.DodajInstruktora", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@ime", instruktor.Osoba.Ime);
                cmd.Parameters.AddWithValue("@prezime", instruktor.Osoba.Prezime);
                cmd.Parameters.AddWithValue("@email", instruktor.Osoba.Email);
                cmd.Parameters.AddWithValue("@specijalnost", instruktor.Specijalnost);
                cmd.Parameters.AddWithValue("@sertifikat",
                    instruktor.Sertifikat != null
                        ? (object)instruktor.Sertifikat
                        : DBNull.Value);

                SqlParameter outParam = new SqlParameter("@newId", SqlDbType.Int)
                { Direction = ParameterDirection.Output };
                cmd.Parameters.Add(outParam);
                cmd.ExecuteNonQuery();

                int noviId = (int)outParam.Value;
                instruktor.Osoba.Id = noviId;

                string lozinkaHash = BCrypt.Net.BCrypt.HashPassword("Instruktor@2026!");
                DodajKorisnika(new Korisnik
                {
                    Email = instruktor.Osoba.Email,
                    LozinkaHash = lozinkaHash,
                    Uloga = "Instruktor",
                    InstruktorId = noviId
                });

                return noviId;
            }
            catch (SqlException ex) { throw new Exception(ex.Message); }
        }

        public void ObrisiInstruktora(int instruktorId)
        {
            try
            {
                using SqlConnection conn = connection.CreateNewConnection();
                using SqlCommand cmd = new SqlCommand("api_studio.ObrisiInstruktora", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@instruktorId", instruktorId);
                cmd.ExecuteNonQuery();
            }
            catch (SqlException ex) { throw new Exception(ex.Message); }
        }

        public List<Instruktor> PrikaziSveInstruktore()
        {
            List<Instruktor> lista = new List<Instruktor>();
            try
            {
                using SqlConnection conn = connection.CreateNewConnection();
                using SqlCommand cmd = new SqlCommand(
                    "SELECT * FROM api_studio.INSTRUKTOR", conn);
                using SqlDataReader reader = cmd.ExecuteReader();
                while (reader.Read())
                    lista.Add(new Instruktor
                    {
                        Osoba = new Osoba
                        {
                            Id = (int)reader["OsobaId"],
                            Ime = (string)reader["Ime"],
                            Prezime = (string)reader["Prezime"],
                            Email = (string)reader["Email"]
                        },
                        Specijalnost = (string)reader["Specijalnost"],
                        Sertifikat = reader["Sertifikat"] == DBNull.Value
                                           ? null : (string)reader["Sertifikat"]
                    });
            }
            catch (SqlException ex) { throw new Exception(ex.Message); }
            return lista;
        }

      

        public int DodajGrupu(Grupa grupa)
        {
            try
            {
                using SqlConnection conn = connection.CreateNewConnection();
                using SqlCommand cmd = new SqlCommand("api_studio.DodajGrupu", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@naziv", grupa.Naziv);
                cmd.Parameters.AddWithValue("@kursId", grupa.Kurs.Id);
                cmd.Parameters.AddWithValue("@koreografId", grupa.Koreograf.Osoba.Id);
                cmd.Parameters.AddWithValue("@predavacId", grupa.Predavac.Osoba.Id);

                SqlParameter outParam = new SqlParameter("@newId", SqlDbType.Int)
                { Direction = ParameterDirection.Output };
                cmd.Parameters.Add(outParam);
                cmd.ExecuteNonQuery();

                int noviId = (int)outParam.Value;
                grupa.Id = noviId;
                return noviId;
            }
            catch (SqlException ex) { throw new Exception(ex.Message); }
        }

        public void IzmeniGrupu(Grupa grupa)
        {
            try
            {
                using SqlConnection conn = connection.CreateNewConnection();
                using SqlCommand cmd = new SqlCommand("api_studio.IzmeniGrupu", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@grupaId", grupa.Id);
                cmd.Parameters.AddWithValue("@naziv", grupa.Naziv);
                cmd.Parameters.AddWithValue("@kursId", grupa.Kurs.Id);
                cmd.Parameters.AddWithValue("@koreografId", grupa.Koreograf.Osoba.Id);
                cmd.Parameters.AddWithValue("@predavacId", grupa.Predavac.Osoba.Id);

                cmd.ExecuteNonQuery();
            }
            catch (SqlException ex) { throw new Exception(ex.Message); }
        }

        public void ObrisiGrupu(int grupaId)
        {
            try
            {
                using SqlConnection conn = connection.CreateNewConnection();
                using SqlCommand cmd = new SqlCommand("api_studio.ObrisiGrupu", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@grupaId", grupaId);
                cmd.ExecuteNonQuery();
            }
            catch (SqlException ex) { throw new Exception(ex.Message); }
        }

        public List<Grupa> PrikaziSveGrupe()
        {
            List<Grupa> lista = new List<Grupa>();
            try
            {
                using SqlConnection conn = connection.CreateNewConnection();
                using SqlCommand cmd = new SqlCommand(
                    "SELECT * FROM api_studio.GRUPA", conn);
                using SqlDataReader reader = cmd.ExecuteReader();
                while (reader.Read())
                    lista.Add(new Grupa
                    {
                        Id = (int)reader["GrupaId"],
                        Naziv = (string)reader["GrupaNaziv"],
                        Kurs = new Kurs
                        {
                            Id = (int)reader["KursId"],
                            Naziv = (string)reader["KursNaziv"]
                        },
                        Koreograf = new Instruktor
                        {
                            Osoba = new Osoba
                            {
                                Id = (int)reader["KoreografId"],
                                Ime = (string)reader["KoreografIme"],
                                Prezime = (string)reader["KoreografPrezime"]
                            }
                        },
                        Predavac = new Instruktor
                        {
                            Osoba = new Osoba
                            {
                                Id = (int)reader["PredavacId"],
                                Ime = (string)reader["PredavacIme"],
                                Prezime = (string)reader["PredavacPrezime"]
                            }
                        },
                        UkupnoUcenika = (int)reader["UkupnoUcenika"]
                    });
            }
            catch (SqlException ex) { throw new Exception(ex.Message); }
            return lista;
        }

        
        public int DodajNastup(Nastup nastup)
        {
            try
            {
                using SqlConnection conn = connection.CreateNewConnection();
                using SqlCommand cmd = new SqlCommand("api_studio.DodajNastup", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@naziv", nastup.Naziv);
                cmd.Parameters.AddWithValue("@datum", nastup.Datum);
                cmd.Parameters.AddWithValue("@lokacija", nastup.Lokacija);
                cmd.Parameters.AddWithValue("@grupaId", nastup.Grupa.Id);
                cmd.Parameters.AddWithValue("@instruktorId", nastup.Organizator.Osoba.Id);

                SqlParameter outParam = new SqlParameter("@newId", SqlDbType.Int)
                { Direction = ParameterDirection.Output };
                cmd.Parameters.Add(outParam);
                cmd.ExecuteNonQuery();

                int noviId = (int)outParam.Value;
                nastup.Id = noviId;
                return noviId;
            }
            catch (SqlException ex) { throw new Exception(ex.Message); }
        }

        public void IzmeniNastup(Nastup nastup)
        {
            try
            {
                using SqlConnection conn = connection.CreateNewConnection();
                using SqlCommand cmd = new SqlCommand("api_studio.IzmeniNastup", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@nastupId", nastup.Id);
                cmd.Parameters.AddWithValue("@naziv", nastup.Naziv);
                cmd.Parameters.AddWithValue("@datum", nastup.Datum);
                cmd.Parameters.AddWithValue("@lokacija", nastup.Lokacija);
                cmd.Parameters.AddWithValue("@grupaId", nastup.Grupa.Id);
                cmd.Parameters.AddWithValue("@instruktorId", nastup.Organizator.Osoba.Id);

                cmd.ExecuteNonQuery();
            }
            catch (SqlException ex) { throw new Exception(ex.Message); }
        }

        public void ObrisiNastup(int nastupId)
        {
            try
            {
                using SqlConnection conn = connection.CreateNewConnection();
                using SqlCommand cmd = new SqlCommand("api_studio.ObrisiNastup", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@nastupId", nastupId);
                cmd.ExecuteNonQuery();
            }
            catch (SqlException ex) { throw new Exception(ex.Message); }
        }

        public List<Nastup> PrikaziSveNastupe()
        {
            List<Nastup> lista = new List<Nastup>();
            try
            {
                using SqlConnection conn = connection.CreateNewConnection();
                using SqlCommand cmd = new SqlCommand(
                    "SELECT * FROM api_studio.NASTUP", conn);
                using SqlDataReader reader = cmd.ExecuteReader();
                while (reader.Read())
                    lista.Add(new Nastup
                    {
                        Id = (int)reader["NastupId"],
                        Naziv = (string)reader["NastupNaziv"],
                        Datum = (DateTime)reader["Datum"],
                        Lokacija = (string)reader["Lokacija"],
                        Grupa = new Grupa
                        {
                            Id = (int)reader["GrupaId"],
                            Naziv = (string)reader["GrupaNaziv"]
                        },
                        Organizator = new Instruktor
                        {
                            Osoba = new Osoba
                            {
                                Id = (int)reader["InstruktorId"],
                                Ime = (string)reader["OrganizatorIme"],
                                Prezime = (string)reader["OrganizatorPrezime"]
                            }
                        }
                    });
            }
            catch (SqlException ex) { throw new Exception(ex.Message); }
            return lista;
        }

        

        public int DodajKostim(Kostim kostim)
        {
            try
            {
                using SqlConnection conn = connection.CreateNewConnection();
                using SqlCommand cmd = new SqlCommand("api_studio.DodajKostim", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@naziv", kostim.Naziv);
                cmd.Parameters.AddWithValue("@velicina", kostim.Velicina);
                cmd.Parameters.AddWithValue("@boja", kostim.Boja);

                SqlParameter outParam = new SqlParameter("@newId", SqlDbType.Int)
                { Direction = ParameterDirection.Output };
                cmd.Parameters.Add(outParam);
                cmd.ExecuteNonQuery();

                int noviId = (int)outParam.Value;
                kostim.Id = noviId;
                return noviId;
            }
            catch (SqlException ex) { throw new Exception(ex.Message); }
        }

        public void IzmeniKostim(Kostim kostim)
        {
            try
            {
                using SqlConnection conn = connection.CreateNewConnection();
                using SqlCommand cmd = new SqlCommand("api_studio.IzmeniKostim", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@kostimId", kostim.Id);
                cmd.Parameters.AddWithValue("@naziv", kostim.Naziv);
                cmd.Parameters.AddWithValue("@velicina", kostim.Velicina);
                cmd.Parameters.AddWithValue("@boja", kostim.Boja);

                cmd.ExecuteNonQuery();
            }
            catch (SqlException ex) { throw new Exception(ex.Message); }
        }

        public void ObrisiKostim(int kostimId)
        {
            try
            {
                using SqlConnection conn = connection.CreateNewConnection();
                using SqlCommand cmd = new SqlCommand("api_studio.ObrisiKostim", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@kostimId", kostimId);
                cmd.ExecuteNonQuery();
            }
            catch (SqlException ex) { throw new Exception(ex.Message); }
        }

        public List<Kostim> PrikaziSveKostime()
        {
            List<Kostim> lista = new List<Kostim>();
            try
            {
                using SqlConnection conn = connection.CreateNewConnection();
                using SqlCommand cmd = new SqlCommand(
                    "SELECT * FROM api_studio.KOSTIM", conn);
                using SqlDataReader reader = cmd.ExecuteReader();
                while (reader.Read())
                    lista.Add(new Kostim
                    {
                        Id = (int)reader["KostimId"],
                        Naziv = (string)reader["Naziv"],
                        Velicina = (string)reader["Velicina"],
                        Boja = (string)reader["Boja"]
                    });
            }
            catch (SqlException ex) { throw new Exception(ex.Message); }
            return lista;
        }

        
        public int DodajKurs(Kurs kurs)
        {
            try
            {
                using SqlConnection conn = connection.CreateNewConnection();
                using SqlCommand cmd = new SqlCommand("api_studio.DodajKurs", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@naziv", kurs.Naziv);
                cmd.Parameters.AddWithValue("@opis",
                    kurs.Opis != null ? (object)kurs.Opis : DBNull.Value);
                cmd.Parameters.AddWithValue("@trajanjeMeseci", kurs.TrajanjeMeseci);
                cmd.Parameters.AddWithValue("@pretKursId",
                    kurs.PretKursId.HasValue
                        ? (object)kurs.PretKursId.Value
                        : DBNull.Value);

                SqlParameter outParam = new SqlParameter("@newId", SqlDbType.Int)
                { Direction = ParameterDirection.Output };
                cmd.Parameters.Add(outParam);
                cmd.ExecuteNonQuery();

                int noviId = (int)outParam.Value;
                kurs.Id = noviId;
                return noviId;
            }
            catch (SqlException ex) { throw new Exception(ex.Message); }
        }

        public void IzmeniKurs(Kurs kurs)
        {
            try
            {
                using SqlConnection conn = connection.CreateNewConnection();
                using SqlCommand cmd = new SqlCommand("api_studio.IzmeniKurs", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@kursId", kurs.Id);
                cmd.Parameters.AddWithValue("@naziv", kurs.Naziv);
                cmd.Parameters.AddWithValue("@opis",
                    kurs.Opis != null ? (object)kurs.Opis : DBNull.Value);
                cmd.Parameters.AddWithValue("@trajanjeMeseci", kurs.TrajanjeMeseci);
                cmd.Parameters.AddWithValue("@pretKursId",
                    kurs.PretKursId.HasValue
                        ? (object)kurs.PretKursId.Value
                        : DBNull.Value);

                cmd.ExecuteNonQuery();
            }
            catch (SqlException ex) { throw new Exception(ex.Message); }
        }

        public void ObrisiKurs(int kursId)
        {
            try
            {
                using SqlConnection conn = connection.CreateNewConnection();
                using SqlCommand cmd = new SqlCommand("api_studio.ObrisiKurs", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@kursId", kursId);
                cmd.ExecuteNonQuery();
            }
            catch (SqlException ex) { throw new Exception(ex.Message); }
        }

        public List<Kurs> PrikaziSveKurseve()
        {
            List<Kurs> lista = new List<Kurs>();
            try
            {
                using SqlConnection conn = connection.CreateNewConnection();
                using SqlCommand cmd = new SqlCommand(
                    "SELECT * FROM api_studio.KURS", conn);
                using SqlDataReader reader = cmd.ExecuteReader();
                while (reader.Read())
                    lista.Add(new Kurs
                    {
                        Id = (int)reader["Id"],
                        Naziv = (string)reader["Naziv"],
                        Opis = reader["Opis"] == DBNull.Value
                                             ? null : (string)reader["Opis"],
                        TrajanjeMeseci = (int)reader["TrajanjeMeseci"],
                        PretKursId = reader["PretKursId"] == DBNull.Value
                                             ? null : (int?)reader["PretKursId"]
                    });
            }
            catch (SqlException ex) { throw new Exception(ex.Message); }
            return lista;
        }

       

        public void DodajZaduzenje(Zaduzenje zaduzenje)
        {
            try
            {
                using SqlConnection conn = connection.CreateNewConnection();
                using SqlCommand cmd = new SqlCommand("api_studio.DodajZaduzenje", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@ucenikId", zaduzenje.Ucenik.Osoba.Id);
                cmd.Parameters.AddWithValue("@nastupId", zaduzenje.Nastup.Id);
                cmd.Parameters.AddWithValue("@kostimId", zaduzenje.Kostim.Id);
                cmd.Parameters.AddWithValue("@datumZaduzenja", zaduzenje.DatumZaduzenja);

                cmd.ExecuteNonQuery();
            }
            catch (SqlException ex) { throw new Exception(ex.Message); }
        }

        public void IzmeniZaduzenje(int ucenikId, int nastupId, int noviKostimId)
        {
            try
            {
                using SqlConnection conn = connection.CreateNewConnection();
                using SqlCommand cmd = new SqlCommand("api_studio.IzmeniZaduzenje", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@ucenikId", ucenikId);
                cmd.Parameters.AddWithValue("@nastupId", nastupId);
                cmd.Parameters.AddWithValue("@noviKostimId", noviKostimId);

                cmd.ExecuteNonQuery();
            }
            catch (SqlException ex) { throw new Exception(ex.Message); }
        }

        public void ObrisiZaduzenje(int ucenikId, int nastupId)
        {
            try
            {
                using SqlConnection conn = connection.CreateNewConnection();
                using SqlCommand cmd = new SqlCommand("api_studio.ObrisiZaduzenje", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@ucenikId", ucenikId);
                cmd.Parameters.AddWithValue("@nastupId", nastupId);

                cmd.ExecuteNonQuery();
            }
            catch (SqlException ex) { throw new Exception(ex.Message); }
        }

        public List<Zaduzenje> PrikaziSvaZaduzenja()
        {
            List<Zaduzenje> lista = new List<Zaduzenje>();
            try
            {
                using SqlConnection conn = connection.CreateNewConnection();
                using SqlCommand cmd = new SqlCommand(
                    "SELECT * FROM api_studio.ZADUZENJE", conn);
                using SqlDataReader reader = cmd.ExecuteReader();


                while (reader.Read())
                {
                    lista.Add(new Zaduzenje
                    {
                        UcenikId = (int)reader["UcenikId"],
                        UcenikIme = (string)reader["UcenikIme"],
                        UcenikPrezime = (string)reader["UcenikPrezime"],
                        NastupId = (int)reader["NastupId"],
                        NastupNaziv = (string)reader["NastupNaziv"],
                        NastupDatum = (DateTime)reader["NastupDatum"],
                        KostimId = (int)reader["KostimId"],
                        KostimNaziv = (string)reader["KostimNaziv"],
                        KostimVelicina = (string)reader["KostimVelicina"],
                        KostimBoja = (string)reader["KostimBoja"],
                        DatumZaduzenja = (DateTime)reader["DatumZaduzenja"]
                    });
                }

            }
            catch (SqlException ex) { throw new Exception(ex.Message); }
            return lista;
        }

        public List<Ucenik> PrikaziUcenicePoInstruktoru(int instruktorId)
        {
            List<Ucenik> lista = new List<Ucenik>();
            try
            {
                using SqlConnection conn = connection.CreateNewConnection();
                using SqlCommand cmd = new SqlCommand(
                    "SELECT * FROM api_studio.GetUceniciPoInstruktoru(@instruktorId)", conn);
                cmd.Parameters.AddWithValue("@instruktorId", instruktorId);

                using SqlDataReader reader = cmd.ExecuteReader();
                while (reader.Read())
                    lista.Add(new Ucenik
                    {
                        Osoba = new Osoba
                        {
                            Id = (int)reader["OsobaId"],
                            Ime = (string)reader["Ime"],
                            Prezime = (string)reader["Prezime"],
                            Email = (string)reader["Email"]
                        },
                        BrojKnjizice = (string)reader["BrojKnjizice"],
                        DatumUpisa = (DateTime)reader["DatumUpisa"],
                        Nivo = (string)reader["Nivo"],
                        GrupaNaziv = (string)reader["GrupaNaziv"],
                        GrupaId = (int)reader["GrupaId"]
                    });
            }
            catch (SqlException ex) { throw new Exception(ex.Message); }
            return lista;
        }

        public List<Zaduzenje> PrikaziZaduzenjaPoInstruktoru(int instruktorId)
        {
            List<Zaduzenje> lista = new List<Zaduzenje>();
            try
            {
                using SqlConnection conn = connection.CreateNewConnection();
                using SqlCommand cmd = new SqlCommand(
                    "SELECT * FROM api_studio.GetZaduzenjaPoInstruktoru(@instruktorId)", conn);
                cmd.Parameters.AddWithValue("@instruktorId", instruktorId);

                using SqlDataReader reader = cmd.ExecuteReader();
                while (reader.Read())
                    lista.Add(new Zaduzenje
                    {
                        UcenikId = (int)reader["UcenikId"],
                        UcenikIme = (string)reader["UcenikIme"],
                        UcenikPrezime = (string)reader["UcenikPrezime"],
                        NastupId = (int)reader["NastupId"],
                        NastupNaziv = (string)reader["NastupNaziv"],
                        NastupDatum = (DateTime)reader["NastupDatum"],
                        KostimId = (int)reader["KostimId"],
                        KostimNaziv = (string)reader["KostimNaziv"],
                        KostimVelicina = (string)reader["KostimVelicina"],
                        KostimBoja = (string)reader["KostimBoja"],
                        DatumZaduzenja = (DateTime)reader["DatumZaduzenja"]
                    });
            }
            catch (SqlException ex) { throw new Exception(ex.Message); }
            return lista;
        }


        public Korisnik? LoginKorisnik(string email, string lozinka)
        {
            try
            {
                using SqlConnection conn = connection.CreateNewConnection();
                using SqlCommand cmd = new SqlCommand("api_studio.LoginKorisnik", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@email", email);

                SqlParameter pUloga = new SqlParameter("@uloga", SqlDbType.NVarChar, 20)
                { Direction = ParameterDirection.Output };
                SqlParameter pLozinkaHash = new SqlParameter("@lozinkaHash", SqlDbType.NVarChar, 256)
                { Direction = ParameterDirection.Output };
                SqlParameter pInstruktorId = new SqlParameter("@instruktorId", SqlDbType.Int)
                { Direction = ParameterDirection.Output };
                SqlParameter pIme = new SqlParameter("@ime", SqlDbType.NVarChar, 50)
                { Direction = ParameterDirection.Output };
                SqlParameter pPrezime = new SqlParameter("@prezime", SqlDbType.NVarChar, 50)
                { Direction = ParameterDirection.Output };

                cmd.Parameters.Add(pUloga);
                cmd.Parameters.Add(pLozinkaHash);
                cmd.Parameters.Add(pInstruktorId);
                cmd.Parameters.Add(pIme);
                cmd.Parameters.Add(pPrezime);

                cmd.ExecuteNonQuery();

                string hash = pLozinkaHash.Value.ToString()!;
                if (!BCrypt.Net.BCrypt.Verify(lozinka, hash)) return null;

                return new Korisnik
                {
                    Email = email,
                    Uloga = (string)pUloga.Value,
                    LozinkaHash = hash,
                    InstruktorId = pInstruktorId.Value == DBNull.Value
                                       ? null : (int?)pInstruktorId.Value,
                    Ime = pIme.Value == DBNull.Value
                                       ? null : (string)pIme.Value,
                    Prezime = pPrezime.Value == DBNull.Value
                                       ? null : (string)pPrezime.Value
                };
            }
            catch (SqlException ex)
            {
                Console.WriteLine($"Грешка LoginKorisnik: [{ex.Number}] {ex.Message}");
                return null;
            }
        }

        public void IzmeniKorisnika(string trenutniEmail, string? ime, string? prezime,
                                    string? noviEmail, string? noviHash)
        {
            try
            {
                using SqlConnection conn = connection.CreateNewConnection();
                using SqlCommand cmd = new SqlCommand("api_studio.IzmeniKorisnika", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@trenutniEmail", trenutniEmail);
                cmd.Parameters.AddWithValue("@ime", (object?)ime ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@prezime", (object?)prezime ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@noviEmail", (object?)noviEmail ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@noviHash", (object?)noviHash ?? DBNull.Value);

                cmd.ExecuteNonQuery();
            }
            catch (SqlException ex) { throw new Exception(ex.Message); }
        }

        public void PromeniLozinkuInstruktora(string email, string noviHash)
        {
            try
            {
                using SqlConnection conn = connection.CreateNewConnection();
                using SqlCommand cmd = new SqlCommand("api_studio.IzmeniKorisnika", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@trenutniEmail", email);
                cmd.Parameters.AddWithValue("@noviHash", noviHash);
                cmd.ExecuteNonQuery();
            }
            catch (SqlException ex) { throw new Exception(ex.Message); }
        }

        public int DodajKorisnika(Korisnik korisnik)
        {
            try
            {
                using SqlConnection conn = connection.CreateNewConnection();
                using SqlCommand cmd = new SqlCommand("api_studio.DodajKorisnika", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@email", korisnik.Email);
                cmd.Parameters.AddWithValue("@lozinkaHash", korisnik.LozinkaHash);
                cmd.Parameters.AddWithValue("@uloga", korisnik.Uloga);
                cmd.Parameters.AddWithValue("@instruktorId",
                    korisnik.InstruktorId.HasValue
                        ? (object)korisnik.InstruktorId.Value
                        : DBNull.Value);

                SqlParameter outParam = new SqlParameter("@newId", SqlDbType.Int)
                { Direction = ParameterDirection.Output };
                cmd.Parameters.Add(outParam);

                cmd.ExecuteNonQuery();

                int noviId = (int)outParam.Value;
                korisnik.Id = noviId;
                return noviId;
            }
            catch (SqlException ex) { throw new Exception(ex.Message); }
        }
    }
}