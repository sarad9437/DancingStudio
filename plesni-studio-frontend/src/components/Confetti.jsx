import { useEffect, useRef, useCallback } from "react";

const COLORS = [
    "#2a1e1e", "#1a1010", "#0d0808",
    "#e8b4b8", "#f2c4c4", "#d4968a",
    "#c9a882", "#e8b4b8", "#f2c4c4",
    "#2a1e1e", "#e8b4b8",
];

const EVENT = "ps-confetti";
export function fireConfetti() {
    window.dispatchEvent(new CustomEvent(EVENT));
}

function rand(a, b) { return a + Math.random() * (b - a); }

function makeParticles(count = 58) {
    const cx = window.innerWidth  / 2;
    const cy = window.innerHeight / 2;
    const out = [];
    for (let i = 0; i < count; i++) {
        const shape = ["rect", "circle", "ribbon"][Math.floor(Math.random() * 3)];
        const angle = rand(15, 165) * Math.PI / 180;
        const spd   = rand(160, 300);
        const side  = Math.random() > 0.5 ? 1 : -1;
        out.push({
            x:    cx + rand(-60, 60),
            y:    cy,
            vx:   Math.cos(angle) * spd * side,
            vy:   -Math.abs(Math.sin(angle) * spd) - rand(40, 100),
            g:    rand(280, 420),
            drag: rand(0.971, 0.992),
            color: COLORS[Math.floor(Math.random() * COLORS.length)],
            shape,
            w:    shape === "ribbon" ? rand(2.5, 4)  : rand(3.5, 7),
            h:    shape === "ribbon" ? rand(7,   14) : rand(3.5, 7),
            rot:  rand(0, 360),
            rotV: rand(-480, 480),
            life:  1,
            decay: rand(0.007, 0.013),
        });
    }
    return out;
}

function drawOne(ctx, p) {
    ctx.save();
    ctx.globalAlpha = Math.max(0, p.life * 0.9);
    ctx.fillStyle   = p.color;
    ctx.strokeStyle = p.color;
    ctx.translate(p.x, p.y);
    ctx.rotate(p.rot * Math.PI / 180);
    if (p.shape === "circle") {
        ctx.beginPath();
        ctx.arc(0, 0, p.w / 2, 0, Math.PI * 2);
        ctx.fill();
    } else if (p.shape === "ribbon") {
        ctx.beginPath();
        ctx.moveTo(-p.w / 2, -p.h / 2);
        ctx.quadraticCurveTo(p.w, 0, -p.w / 2, p.h / 2);
        ctx.lineWidth = p.w;
        ctx.stroke();
    } else {
        ctx.fillRect(-p.w / 2, -p.h / 2, p.w, p.h);
    }
    ctx.restore();
}

export default function Confetti() {
    const canvasRef = useRef(null);
    const stateRef  = useRef({ particles: [], raf: null, last: null });

    const loop = useCallback((ts) => {
        const s   = stateRef.current;
        const cvs = canvasRef.current;
        if (!cvs) return;
        const ctx = cvs.getContext("2d");
        const dt  = s.last ? Math.min((ts - s.last) / 1000, 0.05) : 0.016;
        s.last = ts;

        ctx.clearRect(0, 0, cvs.width, cvs.height);
        s.particles = s.particles.filter(p => p.life > 0.01);

        for (const p of s.particles) {
            p.vy   += p.g    * dt;
            p.vx   *= p.drag;
            p.vy   *= p.drag;
            p.x    += p.vx   * dt;
            p.y    += p.vy   * dt;
            p.rot  += p.rotV * dt;
            p.life -= p.decay;
            drawOne(ctx, p);
        }

        if (s.particles.length > 0) {
            s.raf = requestAnimationFrame(loop);
        } else {
            s.raf  = null;
            s.last = null;
            ctx.clearRect(0, 0, cvs.width, cvs.height);
        }
    }, []);

    const fire = useCallback(() => {
        const s = stateRef.current;
        s.particles.push(...makeParticles(58));
        if (!s.raf) { s.last = null; s.raf = requestAnimationFrame(loop); }
    }, [loop]);

    useEffect(() => {
        const cvs = canvasRef.current;
        const resize = () => {
            cvs.width  = window.innerWidth;
            cvs.height = window.innerHeight;
        };
        resize();
        window.addEventListener("resize", resize);
        return () => window.removeEventListener("resize", resize);
    }, []);

    useEffect(() => {
        window.addEventListener(EVENT, fire);
        return () => window.removeEventListener(EVENT, fire);
    }, [fire]);

    return (
        <canvas
            ref={canvasRef}
            style={{
                position:      "fixed",
                inset:         0,
                pointerEvents: "none",
                zIndex:        99999,
            }}
            aria-hidden="true"
        />
    );
}
