const BASE = "http://localhost:5050/api";

function getToken() {
    try {
        const k = sessionStorage.getItem("ps_korisnik");
        return k ? JSON.parse(k).token : null;
    } catch { return null; }
}

function authHeaders() {
    const token = getToken();
    return {
        "Content-Type": "application/json",
        ...(token ? { "Authorization": `Bearer ${token}` } : {})
    };
}

async function handleResponse(res) {
    if (!res.ok) {
        const err = await res.json().catch(() => ({}));
        throw new Error(err.greska || `Greška ${res.status}`);
    }
    return res.json();
}

export async function changeInstruktorPassword(email, novaLozinka) {
    const res = await fetch(`${BASE}/instruktori/promeni-lozinku`, {
        method: "PUT",
        headers: { "Content-Type": "application/json", ...authHeaders() },
        body: JSON.stringify({ novaLozinka, email })
    });
    const json = await res.json();
    if (!res.ok) throw new Error(json.greska || "Грешка при промени лозинке.");
    return json;
}

export async function updateInstruktor(id, data) {
    const res = await fetch(`${BASE}/instruktori/${id}`, {
        method: "PUT",
        headers: { "Content-Type": "application/json", ...authHeaders() },
        body: JSON.stringify(data)
    });
    const json = await res.json();
    if (!res.ok) throw new Error(json.greska || "Грешка при измени инструктора.");
    return json;
}

export async function dodajUcenicuUGrupu(ucenikId, grupaId) {
    const res = await fetch(`${BASE}/ucenici/${ucenikId}/grupe`, {
        method: "POST",
        headers: { "Content-Type": "application/json", ...authHeaders() },
        body: JSON.stringify({ grupaId })
    });
    const json = await res.json();
    if (!res.ok) throw new Error(json.greska || "Грешка при додавању у групу.");
    return json;
}

export async function izbaciUcenicuIzGrupe(ucenikId, grupaId) {
    const res = await fetch(`${BASE}/ucenici/${ucenikId}/grupe/${grupaId}`, {
        method: "DELETE",
        headers: { ...authHeaders() }
    });
    const json = await res.json();
    if (!res.ok) throw new Error(json.greska || "Грешка при избацивању из групе.");
    return json;
}


export const getUcenici = () =>
    fetch(`${BASE}/ucenici`, { headers: authHeaders() })
    .then(handleResponse);

export const addUcenica = (ucenik, grupaId) =>
    fetch(`${BASE}/ucenici?grupaId=${grupaId}`, {
        method: "POST",
        headers: authHeaders(),
        body: JSON.stringify(ucenik)
    }).then(handleResponse);

export const deleteUcenica = (id) =>
    fetch(`${BASE}/ucenici/${id}`, {
        method: "DELETE",
        headers: authHeaders()
    }).then(handleResponse);

export const updateNivo = (id, noviNivo) =>
    fetch(`${BASE}/ucenici/${id}/nivo`, {
        method: "PUT",
        headers: authHeaders(),
        body: JSON.stringify({ noviNivo })
    }).then(handleResponse);

export const getBrojNastupa = (id) =>
    fetch(`${BASE}/ucenici/${id}/nastupi`, { headers: authHeaders() })
    .then(handleResponse);

export const updateUcenica = (ucenikId, ucenik) =>
    fetch(`${BASE}/ucenici/${ucenikId}`, {
        method: "PUT",
        headers: authHeaders(),
        body: JSON.stringify(ucenik)
    }).then(handleResponse);


export const getInstruktori = () =>
    fetch(`${BASE}/instruktori`, { headers: authHeaders() })
    .then(handleResponse);

export const addInstruktor = (instruktor) =>
    fetch(`${BASE}/instruktori`, {
        method: "POST",
        headers: authHeaders(),
        body: JSON.stringify(instruktor)
    }).then(handleResponse);

export const deleteInstruktor = (id) =>
    fetch(`${BASE}/instruktori/${id}`, {
        method: "DELETE",
        headers: authHeaders()
    }).then(handleResponse);


export const getGrupe = () =>
    fetch(`${BASE}/grupe`, { headers: authHeaders() })
    .then(handleResponse);

export const addGrupa = (grupa) =>
    fetch(`${BASE}/grupe`, {
        method: "POST",
        headers: authHeaders(),
        body: JSON.stringify(grupa)
    }).then(handleResponse);

export const updateGrupa = (id, grupa) =>
    fetch(`${BASE}/grupe/${id}`, {
        method: "PUT",
        headers: authHeaders(),
        body: JSON.stringify(grupa)
    }).then(handleResponse);

export const deleteGrupa = (id) =>
    fetch(`${BASE}/grupe/${id}`, {
        method: "DELETE",
        headers: authHeaders()
    }).then(handleResponse);


export const getNastupi = () =>
    fetch(`${BASE}/nastupi`, { headers: authHeaders() })
    .then(handleResponse);

export const addNastup = (nastup) =>
    fetch(`${BASE}/nastupi`, {
        method: "POST",
        headers: authHeaders(),
        body: JSON.stringify(nastup)
    }).then(handleResponse);

export const updateNastup = (id, nastup) =>
    fetch(`${BASE}/nastupi/${id}`, {
        method: "PUT",
        headers: authHeaders(),
        body: JSON.stringify(nastup)
    }).then(handleResponse);

export const deleteNastup = (id) =>
    fetch(`${BASE}/nastupi/${id}`, {
        method: "DELETE",
        headers: authHeaders()
    }).then(handleResponse);

export const getKostimi = () =>
    fetch(`${BASE}/kostimi`, { headers: authHeaders() })
    .then(handleResponse);

export const addKostim = (kostim) =>
    fetch(`${BASE}/kostimi`, {
        method: "POST",
        headers: authHeaders(),
        body: JSON.stringify(kostim)
    }).then(handleResponse);

export const updateKostim = (id, kostim) =>
    fetch(`${BASE}/kostimi/${id}`, {
        method: "PUT",
        headers: authHeaders(),
        body: JSON.stringify(kostim)
    }).then(handleResponse);

export const deleteKostim = (id) =>
    fetch(`${BASE}/kostimi/${id}`, {
        method: "DELETE",
        headers: authHeaders()
    }).then(handleResponse);


export const getKursevi = () =>
    fetch(`${BASE}/kursevi`, { headers: authHeaders() })
    .then(handleResponse);

export const addKurs = (kurs) =>
    fetch(`${BASE}/kursevi`, {
        method: "POST",
        headers: authHeaders(),
        body: JSON.stringify(kurs)
    }).then(handleResponse);

export const updateKurs = (id, kurs) =>
    fetch(`${BASE}/kursevi/${id}`, {
        method: "PUT",
        headers: authHeaders(),
        body: JSON.stringify(kurs)
    }).then(handleResponse);

export const deleteKurs = (id) =>
    fetch(`${BASE}/kursevi/${id}`, {
        method: "DELETE",
        headers: authHeaders()
    }).then(handleResponse);


export const getZaduzenja = () =>
    fetch(`${BASE}/zaduzenja`, { headers: authHeaders() })
    .then(handleResponse);

export const addZaduzenje = (zaduzenje) =>
    fetch(`${BASE}/zaduzenja`, {
        method: "POST",
        headers: authHeaders(),
        body: JSON.stringify(zaduzenje)
    }).then(handleResponse);

export const updateZaduzenje = (req) =>
    fetch(`${BASE}/zaduzenja`, {
        method: "PUT",
        headers: authHeaders(),
        body: JSON.stringify(req)
    }).then(handleResponse);

export const deleteZaduzenje = (req) =>
    fetch(`${BASE}/zaduzenja`, {
        method: "DELETE",
        headers: authHeaders(),
        body: JSON.stringify(req)
    }).then(handleResponse);