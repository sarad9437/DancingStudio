import { useState } from "react";
import Modal from "../components/Modal";
import PasswordInput from "../components/PasswordInput";
import { addInstruktor, deleteInstruktor, updateInstruktor, changeInstruktorPassword } from "../data/api";

const PRAZNA_FORMA    = { ime: "", prezime: "", email: "", specijalnost: "", sertifikat: "", lozinka: "", lozinka2: "" };
const cirilica = /^[А-ШЂЈЉЊЋЏабвгдђежзијклљмнњопрстћуфхцчџш]/;

export default function InstruktoriPage({ instruktori, grupe, showToast, reload }) {
    const [search,      setSearch]      = useState("");
    const [showAdd,     setShowAdd]     = useState(false);
    const [showDel,     setShowDel]     = useState(null);
    const [showEdit,    setShowEdit]    = useState(null);
    const [loading,     setLoading]     = useState(false);
    const [forma,       setForma]       = useState(PRAZNA_FORMA);

    const zatvoriAdd  = () => { setShowAdd(false);  setForma(PRAZNA_FORMA); };
    const zatvoriEdit = () => { setShowEdit(null);  setForma(PRAZNA_FORMA); };

    const otvoriEdit = (i) => {
        setForma({
            ime:          i.osoba.ime,
            prezime:      i.osoba.prezime,
            email:        i.osoba.email,
            specijalnost: i.specijalnost,
            sertifikat:   i.sertifikat || "",
            lozinka:      "",
            lozinka2:     ""
        });
        setShowEdit(i);
    };

    const filtered = instruktori.filter(i =>
        `${i.osoba.ime} ${i.osoba.prezime}`.toLowerCase()
            .includes(search.toLowerCase())
    );

    const isAktivan = (id) =>
        grupe.some(g => g.koreograf?.osoba?.id === id || g.predavac?.osoba?.id === id);

    // ── Dodaj ────────────────────────────────────────────
    const handleAdd = async () => {
        if (!cirilica.test(forma.ime)) {
            showToast("Ime мора започети великим словом ћирилице.", "error"); return;
        }
        if (!cirilica.test(forma.prezime)) {
            showToast("Презиме мора започети великим словом ћирилице.", "error"); return;
        }
        if (!cirilica.test(forma.specijalnost)) {
            showToast("Специјалност мора започети великим словом ћирилице.", "error"); return;
        }
        setLoading(true);
        try {
            await addInstruktor({
                osoba:        { ime: forma.ime, prezime: forma.prezime, email: forma.email },
                specijalnost: forma.specijalnost,
                sertifikat:   forma.sertifikat || null
            });
            showToast("Инструктор успешно додат.", "success");
            zatvoriAdd();
            reload();
        } catch (err) {
            showToast("Грешка: " + err.message, "error");
        } finally {
            setLoading(false);
        }
    };

    // ── Izmeni ────────────────────────────────────────────
    const handleEdit = async () => {
        if (!cirilica.test(forma.ime)) {
            showToast("Ime мора започети великим словом ћирилице.", "error"); return;
        }
        if (!cirilica.test(forma.prezime)) {
            showToast("Презиме мора започети великим словом ћирилице.", "error"); return;
        }
        if (!cirilica.test(forma.specijalnost)) {
            showToast("Специјалност мора започети великим словом ћирилице.", "error"); return;
        }
        if (forma.lozinka && forma.lozinka !== forma.lozinka2) {
            showToast("Лозинке се не поклапају.", "error"); return;
        }
        if (forma.lozinka && forma.lozinka.length < 6) {
            showToast("Лозинка мора имати барем 6 карактера.", "error"); return;
        }
        setLoading(true);
        try {
            await updateInstruktor(showEdit.osoba.id, {
                osoba:        { ime: forma.ime, prezime: forma.prezime, email: forma.email },
                specijalnost: forma.specijalnost,
                sertifikat:   forma.sertifikat || null
            });
            if (forma.lozinka) {
                await changeInstruktorPassword(showEdit.osoba.email, forma.lozinka);
            }
            showToast("Инструктор успешно измењен.", "success");
            zatvoriEdit();
            reload();
        } catch (err) {
            showToast("Грешка: " + err.message, "error");
        } finally {
            setLoading(false);
        }
    };

    // ── Obrisi ────────────────────────────────────────────
    const handleDelete = async () => {
        setLoading(true);
        try {
            await deleteInstruktor(showDel.osoba.id);
            showToast("Инструктор обрисан.", "success");
            setShowDel(null);
            reload();
        } catch (err) {
            showToast("Грешка: " + err.message, "error");
        } finally {
            setLoading(false);
        }
    };

    return (
        <div>
            <div className="ph">
                <h2>Инструктори</h2>
                <p>Управљање инструкторима плесног студија · {filtered.length} резултата</p>
            </div>

            <div className="toolbar">
                <div className="sb-search">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
                        stroke="currentColor" strokeWidth="2"
                        style={{ color: "var(--ink-muted)", flexShrink: 0 }}>
                        <circle cx="11" cy="11" r="8"/>
                        <line x1="21" y1="21" x2="16.65" y2="16.65"/>
                    </svg>
                    <input
                        placeholder="Претрага по имену или презимену..."
                        value={search}
                        onChange={e => setSearch(e.target.value)}
                    />
                    {search && (
                        <button onClick={() => setSearch("")}
                            style={{ background:"none", border:"none", cursor:"pointer",
                                color:"var(--ink-muted)", padding:0, fontSize:14, lineHeight:1 }}>
                            ✕
                        </button>
                    )}
                </div>
                <button className="btn btn-p" onClick={() => setShowAdd(true)}>
                    + Додај инструктора
                </button>
            </div>

            <div className="card">
                {filtered.length === 0 ? (
                    <div className="empty">
                        <p>{search ? `Нема резултата за „${search}"` : "Нема инструктора."}</p>
                    </div>
                ) : (
                    <div className="tw">
                        <table>
                            <thead>
                                <tr>
                                    <th>Инструктор</th>
                                    <th>Е-пошта</th>
                                    <th>Специјалност</th>
                                    <th>Сертификат</th>
                                    <th>Акције</th>
                                </tr>
                            </thead>
                            <tbody>
                                {filtered.map(i => (
                                    <tr key={i.osoba.id}>
                                        <td>
                                            <div style={{ display:"flex", alignItems:"center", gap:10 }}>
                                                <div className="rav" style={{ fontSize:11 }}>
                                                    {i.osoba.ime?.[0]}{i.osoba.prezime?.[0]}
                                                </div>
                                                <strong>{i.osoba.ime} {i.osoba.prezime}</strong>
                                            </div>
                                        </td>
                                        <td>{i.osoba.email}</td>
                                        <td>{i.specijalnost}</td>
                                        <td>
                                            {i.sertifikat ? (
                                                <span style={{ fontFamily:"Montserrat", fontSize:12,
                                                    background:"var(--petal)", padding:"2px 7px",
                                                    borderRadius:6 }}>
                                                    {i.sertifikat}
                                                </span>
                                            ) : "—"}
                                        </td>
                                        <td>
                                            <div className="acts">
                                                <button
                                                    className="btn btn-g btn-sm"
                                                    onClick={() => otvoriEdit(i)}
                                                >
                                                    Измени
                                                </button>
                                                <button
                                                    className="btn btn-d btn-sm"
                                                    onClick={() => setShowDel(i)}
                                                    disabled={isAktivan(i.osoba.id)}
                                                    title={isAktivan(i.osoba.id)
                                                        ? "Не може се обрисати – активан у групи"
                                                        : "Обриши"}
                                                >
                                                    Обриши
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                )}
            </div>

            {/* ── Modal: Додај ── */}
            {showAdd && (
                <Modal
                    title="Додај инструктора"
                    onClose={zatvoriAdd}
                    footer={<>
                        <button className="btn btn-g" onClick={zatvoriAdd}>Откажи</button>
                        <button className="btn btn-p" onClick={handleAdd} disabled={loading}>
                            {loading ? "Чекај..." : "Додај инструктора"}
                        </button>
                    </>}
                >
                    <div className="fg">
                        <div>
                            <label>Ime</label>
                            <input value={forma.ime}
                                onChange={e => setForma({ ...forma, ime: e.target.value })}
                                placeholder="нпр. Биљана" />
                        </div>
                        <div>
                            <label>Презиме</label>
                            <input value={forma.prezime}
                                onChange={e => setForma({ ...forma, prezime: e.target.value })}
                                placeholder="нпр. Марчић" />
                        </div>
                        <div className="full">
                            <label>Е-пошта</label>
                            <input value={forma.email}
                                onChange={e => setForma({ ...forma, email: e.target.value })}
                                placeholder="biljana.marcic@gmail.com" />
                        </div>
                        <div>
                            <label>Специјалност</label>
                            <input value={forma.specijalnost}
                                onChange={e => setForma({ ...forma, specijalnost: e.target.value })}
                                placeholder="нпр. Народни плес" />
                        </div>
                        <div>
                            <label>Сертификат (необавезно)</label>
                            <input value={forma.sertifikat}
                                onChange={e => setForma({ ...forma, sertifikat: e.target.value })}
                                placeholder="нпр. IDO 2022" />
                        </div>
                    </div>
                </Modal>
            )}

            {/* ── Modal: Измени ── */}
            {showEdit && (
                <Modal
                    title={`Измени инструктора — ${showEdit.osoba.ime} ${showEdit.osoba.prezime}`}
                    onClose={zatvoriEdit}
                    footer={<>
                        <button className="btn btn-g" onClick={zatvoriEdit}>Откажи</button>
                        <button className="btn btn-p" onClick={handleEdit} disabled={loading}>
                            {loading ? "Чекај..." : "Сачувај измене"}
                        </button>
                    </>}
                >
                    <div className="fg">
                        <div>
                            <label>Ime</label>
                            <input value={forma.ime}
                                onChange={e => setForma({ ...forma, ime: e.target.value })}
                                placeholder="нпр. Биљана" />
                        </div>
                        <div>
                            <label>Презиме</label>
                            <input value={forma.prezime}
                                onChange={e => setForma({ ...forma, prezime: e.target.value })}
                                placeholder="нпр. Марчић" />
                        </div>
                        <div className="full">
                            <label>Е-пошта</label>
                            <input value={forma.email}
                                onChange={e => setForma({ ...forma, email: e.target.value })}
                                placeholder="biljana.marcic@gmail.com" />
                        </div>
                        <div>
                            <label>Специјалност</label>
                            <input value={forma.specijalnost}
                                onChange={e => setForma({ ...forma, specijalnost: e.target.value })}
                                placeholder="нпр. Народни плес" />
                        </div>
                        <div>
                            <label>Сертификат (необавезно)</label>
                            <input value={forma.sertifikat}
                                onChange={e => setForma({ ...forma, sertifikat: e.target.value })}
                                placeholder="нпр. IDO 2022" />
                        </div>
                        <div style={{ gridColumn:"1 / -1", height:1,
                            background:"var(--border)", margin:"4px 0" }} />
                        <div>
                            <label>Нова лозинка (необавезно)</label>
                            <PasswordInput
                                value={forma.lozinka}
                                onChange={e => setForma({ ...forma, lozinka: e.target.value })}
                                placeholder="Оставите празно ако не мењате"
                            />
                        </div>
                        <div>
                            <label>Потврди лозинку</label>
                            <PasswordInput
                                value={forma.lozinka2}
                                onChange={e => setForma({ ...forma, lozinka2: e.target.value })}
                                placeholder="Поновите нову лозинку"
                            />
                        </div>
                    </div>
                </Modal>
            )}

            {/* ── Modal: Обриши ── */}
            {showDel && (
                <Modal
                    title="Потврди брисање"
                    onClose={() => setShowDel(null)}
                    footer={<>
                        <button className="btn btn-g" onClick={() => setShowDel(null)}>Откажи</button>
                        <button className="btn btn-d" onClick={handleDelete} disabled={loading}>
                            {loading ? "Чекај..." : "Обриши"}
                        </button>
                    </>}
                >
                    <p className="cmsg">
                        Да ли сте сигурни да желите да обришете инструктора{" "}
                        <span className="chl">{showDel.osoba.ime} {showDel.osoba.prezime}</span>?
                    </p>
                </Modal>
            )}
        </div>
    );
}