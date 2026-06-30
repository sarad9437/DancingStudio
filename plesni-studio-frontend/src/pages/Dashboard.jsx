import { formatDate } from "../data/dateUtils";

export default function Dashboard({ ucenici, instruktori, grupe, nastupi, zaduzenja, kostimi, kursevi, korisnik }) {
    const isAdmin = korisnik?.uloga === "Admin";
    const instruktorId = korisnik?.instruktorId;

    const now = new Date();

    const mojeGrupe = isAdmin
        ? grupe
        : grupe.filter(g =>
            g.koreograf?.osoba?.id === instruktorId ||
            g.predavac?.osoba?.id  === instruktorId
        );

    const mojiNastupi = isAdmin
        ? nastupi
        : nastupi.filter(n =>
            mojeGrupe.some(g => g.id === n.grupa?.id) ||
            n.organizator?.osoba?.id === instruktorId
        );

    const mojiUcenici = isAdmin ? ucenici : ucenici;

    const poslednjeUcenice = [...mojiUcenici].slice(-5).reverse();

    const skorNastupi = [...mojiNastupi]
        .sort((a, b) => new Date(b.datum) - new Date(a.datum))
        .slice(0, 5);

    const ime = isAdmin
        ? "Плесни студио"
        : `${korisnik?.ime ?? ""} ${korisnik?.prezime ?? ""}`.trim();

    return (
        <div>
            <div style={{
                marginBottom: 28,
                paddingBottom: 20,
                borderBottom: "1px solid rgba(201,168,130,0.2)"
            }}>
                <h1 style={{
                    fontFamily: "'Playfair Display', serif",
                    fontSize: 36,
                    fontWeight: 400,
                    fontStyle: "italic",
                    color: "#1e1414",
                    lineHeight: 1.05,
                    letterSpacing: "-0.01em",
                    marginBottom: 10
                }}>
                    {ime}
                </h1>
                <p style={{
                    fontSize: 12,
                    letterSpacing: "0.22em",
                    textTransform: "uppercase",
                    color: "#b07878",
                    fontWeight: 500
                }}>
                    {now.toLocaleDateString("sr-Latn-RS", { weekday: "long", day: "numeric", month: "long", year: "numeric" })}
                </p>
            </div>

            <div className="stats">
                <div className="sc">
                    <div className="sc-lbl">{isAdmin ? "Број ученика" : "Моји ученици"}</div>
                    <div className="sc-val">{mojiUcenici.length}</div>
                    <div className="sc-sub">{isAdmin ? "уписаних у студио" : "у мојим групама"}</div>
                </div>
                {isAdmin && (
                    <div className="sc">
                        <div className="sc-lbl">Број инструктора</div>
                        <div className="sc-val">{instruktori.length}</div>
                        <div className="sc-sub">активних</div>
                    </div>
                )}
                <div className="sc">
                    <div className="sc-lbl">{isAdmin ? "Број група" : "Моје групе"}</div>
                    <div className="sc-val">{mojeGrupe.length}</div>
                    <div className="sc-sub">у раду</div>
                </div>
                <div className="sc">
                    <div className="sc-lbl">{isAdmin ? "Број наступа" : "Моји наступи"}</div>
                    <div className="sc-val">{mojiNastupi.length}</div>
                    <div className="sc-sub">забележено</div>
                </div>
                {isAdmin && (
                    <>
                        <div className="sc">
                            <div className="sc-lbl">Задужења</div>
                            <div className="sc-val">{zaduzenja?.length ?? 0}</div>
                            <div className="sc-sub">укупно</div>
                        </div>
                        <div className="sc">
                            <div className="sc-lbl">Костими</div>
                            <div className="sc-val">{kostimi?.length ?? 0}</div>
                            <div className="sc-sub">у инвентару</div>
                        </div>
                        <div className="sc">
                            <div className="sc-lbl">Курсеви</div>
                            <div className="sc-val">{kursevi?.length ?? 0}</div>
                            <div className="sc-sub">доступних</div>
                        </div>
                    </>
                )}
            </div>

            <div className="dash-grid">

                <div className="card">
                    <div className="card-head">
                        <div className="card-title">
                            {isAdmin ? "Последње уписани" : "Моји ученици"}
                        </div>
                    </div>
                    {poslednjeUcenice.length === 0 ? (
                        <div className="empty">
                            <p>Нема уписаних ученика</p>
                        </div>
                    ) : (
                        <ul className="rl">
                            {poslednjeUcenice.map(u => (
                                <li className="ri" key={u.osoba.id}>
                                    <div className="rav">
                                        {u.osoba.ime?.[0]}{u.osoba.prezime?.[0]}
                                    </div>
                                    <div>
                                        <div className="rname">
                                            {u.osoba.ime} {u.osoba.prezime}
                                        </div>
                                        <div className="rsub">{u.nivo}</div>
                                    </div>
                                    <div style={{
                                        marginLeft: "auto",
                                        fontSize: 14,
                                        color: "var(--brown-mid)",
                                        fontWeight: 400,
                                        letterSpacing: "0.04em"
                                    }}>
                                        {formatDate(u.datumUpisa)}
                                    </div>
                                </li>
                            ))}
                        </ul>
                    )}
                </div>

                <div className="card">
                    <div className="card-head">
                        <div className="card-title">
                            {isAdmin ? "Наступи" : "Предстојећи наступи"}
                        </div>
                    </div>
                    {skorNastupi.length === 0 ? (
                        <div className="empty">
                            <p>Нема забележених наступа</p>
                        </div>
                    ) : (
                        <ul className="rl">
                            {skorNastupi.map(n => (
                                <li className="ri" key={n.id}>
                                    <div>
                                        <div className="rname">{n.naziv}</div>
                                        <div className="rsub">{n.lokacija}</div>
                                    </div>
                                    <div style={{
                                        marginLeft: "auto",
                                        fontSize: 13,
                                        color: "var(--brown-mid)",
                                        fontWeight: 400,
                                        whiteSpace: "nowrap"
                                    }}>
                                        {formatDate(n.datum)}
                                    </div>
                                </li>
                            ))}
                        </ul>
                    )}
                </div>

                <div className="card">
                    <div className="card-head">
                        <div className="card-title">
                            {isAdmin ? "Групе" : "Моје групе"}
                        </div>
                    </div>
                    {mojeGrupe.length === 0 ? (
                        <div className="empty"><p>Нема група</p></div>
                    ) : (
                        <ul className="rl">
                            {mojeGrupe.slice(0, 5).map(g => (
                                <li className="ri" key={g.id}>
                                    <div className="rav" style={{fontSize: 10, fontStyle: "italic", fontFamily: "var(--font-display)"}}>
                                        {g.naziv?.[0]}
                                    </div>
                                    <div>
                                        <div className="rname">{g.naziv}</div>
                                        <div className="rsub">{g.kurs?.naziv}</div>
                                    </div>
                                    <div style={{
                                        marginLeft: "auto",
                                        fontSize: 14,
                                        color: "var(--brown-mid)",
                                        fontWeight: 400
                                    }}>
                                        {g.ukupnoUcenika} ученика
                                    </div>
                                </li>
                            ))}
                        </ul>
                    )}
                </div>

                {isAdmin && (
                    <div className="card">
                        <div className="card-head">
                            <div className="card-title">Инструктори</div>
                        </div>
                        {instruktori.length === 0 ? (
                            <div className="empty"><p>Нема инструктора</p></div>
                        ) : (
                            <ul className="rl">
                                {instruktori.slice(0, 5).map(i => (
                                    <li className="ri" key={i.osoba.id}>
                                        <div className="rav">
                                            {i.osoba.ime?.[0]}{i.osoba.prezime?.[0]}
                                        </div>
                                        <div>
                                            <div className="rname">
                                                {i.osoba.ime} {i.osoba.prezime}
                                            </div>
                                            <div className="rsub">{i.specijalnost}</div>
                                        </div>
                                    </li>
                                ))}
                            </ul>
                        )}
                    </div>
                )}

                {!isAdmin && (
                    <div className="card">
                        <div className="card-head">
                            <div className="card-title">Мој профил</div>
                        </div>
                        <ul className="rl">
                            <li className="ri">
                                <div className="rav">
                                    {korisnik?.ime?.[0]}{korisnik?.prezime?.[0]}
                                </div>
                                <div>
                                    <div className="rname">{korisnik?.ime} {korisnik?.prezime}</div>
                                    <div className="rsub">{korisnik?.email}</div>
                                </div>
                            </li>
                        </ul>
                    </div>
                )}
            </div>
        </div>
    );
}