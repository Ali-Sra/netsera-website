export function HeroMachine() {
  const binaries = ["01010110", "10100101", "01101001", "11001010"];

  return (
    <div className="hero-machine" aria-label="Animierte Darstellung eines KI-Operators, der Binärdaten in ein IT-System überträgt">
      <div className="hero-machine__halo" aria-hidden="true" />
      <div className="hero-machine__binary hero-machine__binary--a" aria-hidden="true">
        {binaries[0]}
      </div>
      <div className="hero-machine__binary hero-machine__binary--b" aria-hidden="true">
        {binaries[1]}
      </div>
      <div className="hero-machine__binary hero-machine__binary--c" aria-hidden="true">
        {binaries[2]}
      </div>

      <svg
        className="hero-machine__svg"
        viewBox="0 0 720 620"
        role="img"
        aria-labelledby="hero-machine-title hero-machine-desc"
      >
        <title id="hero-machine-title">Netsera AI Infrastructure Operator</title>
        <desc id="hero-machine-desc">
          Ein futuristischer Operator verarbeitet Binärdaten und überträgt sie auf ein Terminal mit Infrastrukturstatus.
        </desc>

        <defs>
          <linearGradient id="machineStroke" x1="0" x2="1">
            <stop offset="0%" stopColor="#35e6b4" />
            <stop offset="100%" stopColor="#77b8ff" />
          </linearGradient>
          <radialGradient id="brainGlow">
            <stop offset="0%" stopColor="#35e6b4" stopOpacity=".36" />
            <stop offset="100%" stopColor="#35e6b4" stopOpacity="0" />
          </radialGradient>
          <filter id="softGlow">
            <feGaussianBlur stdDeviation="7" result="blur" />
            <feMerge>
              <feMergeNode in="blur" />
              <feMergeNode in="SourceGraphic" />
            </feMerge>
          </filter>
        </defs>

        <g opacity=".35" stroke="#8da6bd" strokeWidth="1">
          <path d="M38 92H682M38 172H682M38 252H682M38 332H682M38 412H682M38 492H682" />
          <path d="M118 42V568M218 42V568M318 42V568M418 42V568M518 42V568M618 42V568" />
        </g>

        <g className="hero-machine__network" fill="none" stroke="url(#machineStroke)" strokeWidth="2">
          <path d="M84 456C156 410 179 401 245 404" />
          <path d="M245 404C310 405 335 384 376 345" />
          <path d="M376 345C440 297 471 278 552 277" />
          <circle cx="84" cy="456" r="5" fill="#35e6b4" />
          <circle cx="245" cy="404" r="5" fill="#35e6b4" />
          <circle cx="376" cy="345" r="5" fill="#77b8ff" />
          <circle cx="552" cy="277" r="5" fill="#77b8ff" />
        </g>

        <g className="hero-machine__operator">
          <ellipse cx="274" cy="202" rx="98" ry="96" fill="url(#brainGlow)" />
          <path
            d="M222 205c0-55 36-92 82-92 44 0 79 32 83 81l-8 53c-5 28-30 48-59 48h-37c-31 0-56-24-59-54l-2-36Z"
            fill="#0c1826"
            stroke="url(#machineStroke)"
            strokeWidth="3"
          />
          <path d="M240 188c28-44 82-52 124-14" fill="none" stroke="#7892a8" strokeWidth="2" />
          <path d="M252 220h32M327 220h31" stroke="#35e6b4" strokeWidth="4" strokeLinecap="round" />
          <path d="M291 260c13 8 30 8 43 0" fill="none" stroke="#8aa1b4" strokeWidth="2" strokeLinecap="round" />
          <circle cx="270" cy="220" r="4" fill="#35e6b4" filter="url(#softGlow)" />
          <circle cx="343" cy="220" r="4" fill="#35e6b4" filter="url(#softGlow)" />

          <g className="hero-machine__brain" filter="url(#softGlow)">
            <path
              d="M263 166c7-17 20-28 38-29 18-1 33 7 44 23 8 12 11 28 7 43-3 11-9 20-18 27h-58c-10-9-17-21-20-35-2-11 1-20 7-29Z"
              fill="#0d2a2a"
              stroke="#35e6b4"
              strokeWidth="2"
            />
            <path d="M278 159l18 21 20-26 18 28-13 25-28 2-20-23 5-27Z" fill="none" stroke="#35e6b4" strokeWidth="1.5" />
            <circle cx="296" cy="181" r="3" fill="#a6ffe8" />
            <circle cx="316" cy="155" r="3" fill="#a6ffe8" />
            <circle cx="334" cy="183" r="3" fill="#a6ffe8" />
            <circle cx="293" cy="209" r="3" fill="#a6ffe8" />
          </g>

          <path
            d="M237 298c-37 15-62 45-70 91l-18 119h247l-23-122c-8-43-36-74-73-88"
            fill="#0a1522"
            stroke="#53687b"
            strokeWidth="2"
          />
          <path d="M241 315c22 26 46 39 73 39 28 0 54-13 76-39" fill="none" stroke="#35e6b4" strokeOpacity=".55" strokeWidth="2" />
          <path d="M196 385h168" stroke="#1f3444" strokeWidth="2" />
          <circle cx="280" cy="420" r="22" fill="#07111b" stroke="#35e6b4" strokeWidth="2" />
          <path d="M272 420h16M280 412v16" stroke="#35e6b4" strokeWidth="2" strokeLinecap="round" />
        </g>

        <g className="hero-machine__data-path">
          <path
            d="M347 177C411 160 443 170 476 205S525 257 589 255"
            fill="none"
            stroke="#35e6b4"
            strokeWidth="2"
            strokeDasharray="7 11"
          />
          <circle cx="366" cy="174" r="4" fill="#35e6b4" />
          <circle cx="425" cy="180" r="4" fill="#35e6b4" />
          <circle cx="482" cy="213" r="4" fill="#35e6b4" />
          <circle cx="535" cy="253" r="4" fill="#35e6b4" />
        </g>

        <g className="hero-machine__terminal">
          <path d="M465 206h205v215H465z" rx="16" fill="#08131f" stroke="#405469" strokeWidth="2" />
          <path d="M480 222h174v184H480z" rx="10" fill="#06101a" stroke="#1f3446" />
          <rect x="494" y="238" width="70" height="9" rx="4" fill="#173d37" />
          <rect x="494" y="258" width="126" height="5" rx="2" fill="#1c2d3b" />
          <rect x="494" y="271" width="94" height="5" rx="2" fill="#1c2d3b" />

          {[
            ["SERVER", 302],
            ["FIREWALL", 329],
            ["M365", 356],
            ["BACKUP", 383],
          ].map(([label, y]) => (
            <g key={label}>
              <rect x="494" y={Number(y) - 14} width="142" height="22" rx="7" fill="#0b1b27" stroke="#1e3946" />
              <circle cx="508" cy={Number(y) - 3} r="3" fill="#35e6b4" />
              <text x="519" y={Number(y)} fill="#b9c9d6" fontSize="9" fontFamily="monospace">
                {label}
              </text>
              <text x="596" y={Number(y)} fill="#35e6b4" fontSize="8" fontFamily="monospace">
                ONLINE
              </text>
            </g>
          ))}

          <path d="M537 421h66l11 29h-88l11-29Z" fill="#111f2d" stroke="#405469" />
          <path d="M509 450h122" stroke="#405469" strokeWidth="3" strokeLinecap="round" />
        </g>

        <g className="hero-machine__terminal-binary" fill="#35e6b4" fontFamily="monospace" fontSize="11">
          <text x="499" y="252">010101001101</text>
          <text x="533" y="288">10101001</text>
        </g>
      </svg>

      <div className="hero-machine__status" aria-hidden="true">
        <span className="status-dot" />
        LIVE DATA PIPELINE
      </div>
    </div>
  );
}
