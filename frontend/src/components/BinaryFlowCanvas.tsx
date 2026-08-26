"use client";

import { useEffect, useRef } from "react";

type Point = [number, number];

type Particle = {
  t: number;
  speed: number;
  lane: number;
  digit: "0" | "1";
  size: number;
  alpha: number;
  phase: number;
};

function bezier(
  t: number,
  p0: Point,
  p1: Point,
  p2: Point,
  p3: Point
) {
  const u = 1 - t;
  const tt = t * t;
  const uu = u * u;
  const uuu = uu * u;
  const ttt = tt * t;

  return {
    x:
      uuu * p0[0] +
      3 * uu * t * p1[0] +
      3 * u * tt * p2[0] +
      ttt * p3[0],
    y:
      uuu * p0[1] +
      3 * uu * t * p1[1] +
      3 * u * tt * p2[1] +
      ttt * p3[1],
  };
}

export function BinaryFlowCanvas() {
  const canvasRef = useRef<HTMLCanvasElement | null>(null);

  useEffect(() => {
    const canvasElement = canvasRef.current;

    if (!canvasElement) {
      return;
    }

    // Explicit non-null types for nested functions.
    const canvas: HTMLCanvasElement = canvasElement;
    const context = canvas.getContext("2d");

    if (!context) {
      return;
    }

    const ctx: CanvasRenderingContext2D = context;

    const reducedMotion = window.matchMedia(
      "(prefers-reduced-motion: reduce)"
    ).matches;

    let animationFrame = 0;
    let width = 0;
    let height = 0;
    let dpr = Math.min(window.devicePixelRatio || 1, 2);

    const particleCount = reducedMotion ? 80 : 520;

    const particles: Particle[] = Array.from(
      { length: particleCount },
      (_, index) => ({
        t: (index / particleCount + Math.random() * 0.15) % 1,
        speed: 0.0014 + Math.random() * 0.002,
        lane: Math.floor(Math.random() * 13) - 6,
        digit: Math.random() > 0.5 ? "1" : "0",
        size: 10 + Math.random() * 8,
        alpha: 0.45 + Math.random() * 0.55,
        phase: Math.random() * Math.PI * 2,
      })
    );

    function resize() {
      const rect = canvas.getBoundingClientRect();

      width = Math.max(1, rect.width);
      height = Math.max(1, rect.height);
      dpr = Math.min(window.devicePixelRatio || 1, 2);

      canvas.width = Math.floor(width * dpr);
      canvas.height = Math.floor(height * dpr);

      ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    }

    function draw(time: number) {
      ctx.clearRect(0, 0, width, height);

      const brain: Point = [width * 0.49, height * 0.34];
      const hand: Point = [width * 0.69, height * 0.75];
      const screen: Point = [width * 0.83, height * 0.54];

      const glow = ctx.createRadialGradient(
        brain[0],
        brain[1],
        0,
        brain[0],
        brain[1],
        90
      );

      glow.addColorStop(0, "rgba(77,255,203,.42)");
      glow.addColorStop(0.35, "rgba(77,255,203,.16)");
      glow.addColorStop(1, "rgba(77,255,203,0)");

      ctx.fillStyle = glow;
      ctx.beginPath();
      ctx.arc(brain[0], brain[1], 90, 0, Math.PI * 2);
      ctx.fill();

      // Main luminous path: brain -> hand -> screen
      ctx.save();
      ctx.lineCap = "round";
      ctx.lineWidth = 2.2;
      ctx.strokeStyle = "rgba(68,255,196,.8)";
      ctx.shadowColor = "rgba(61,255,195,.75)";
      ctx.shadowBlur = 14;

      ctx.beginPath();
      ctx.moveTo(brain[0], brain[1]);
      ctx.bezierCurveTo(
        width * 0.53,
        height * 0.47,
        width * 0.58,
        height * 0.66,
        hand[0],
        hand[1]
      );
      ctx.bezierCurveTo(
        width * 0.74,
        height * 0.74,
        width * 0.79,
        height * 0.66,
        screen[0],
        screen[1]
      );
      ctx.stroke();
      ctx.restore();

      for (const particle of particles) {
        if (!reducedMotion) {
          particle.t += particle.speed;

          if (particle.t > 1) {
            particle.t -= 1;
            particle.digit = Math.random() > 0.5 ? "1" : "0";
          }
        }

        let x = 0;
        let y = 0;
        let angle = 0;

        if (particle.t < 0.48) {
          // Wide binary curtain -> funnel into brain
          const progress = particle.t / 0.48;
          const startX =
            width * (0.08 + ((particle.lane + 6) / 12) * 0.73);
          const startY = -28;
          const targetX = brain[0] + particle.lane * 3.4;
          const targetY = brain[1] - 4 + particle.lane * 1.8;

          const ease =
            progress * progress * (3 - 2 * progress);

          x = startX + (targetX - startX) * ease;
          y = startY + (targetY - startY) * progress;

          const wobble =
            Math.sin(time * 0.002 + particle.phase) *
            5 *
            (1 - progress);

          x += wobble;
          angle = Math.atan2(
            targetY - startY,
            targetX - startX
          );
        } else if (particle.t < 0.8) {
          // Brain -> arm/hand
          const progress = (particle.t - 0.48) / 0.32;

          const point = bezier(
            progress,
            brain,
            [width * 0.52, height * 0.45],
            [width * 0.58, height * 0.68],
            hand
          );

          x = point.x + particle.lane * 1.3;
          y = point.y + particle.lane * 0.6;
          angle = 0.35;
        } else {
          // Hand -> screen
          const progress = (particle.t - 0.8) / 0.2;

          const point = bezier(
            progress,
            hand,
            [width * 0.74, height * 0.74],
            [width * 0.79, height * 0.63],
            screen
          );

          x = point.x + particle.lane;
          y = point.y + particle.lane * 0.4;
          angle = -0.18;
        }

        const pulse =
          0.72 +
          Math.sin(time * 0.004 + particle.phase) * 0.18;

        ctx.save();
        ctx.translate(x, y);
        ctx.rotate(angle);
        ctx.globalAlpha = Math.max(
          0.15,
          particle.alpha * pulse
        );
        ctx.font = `700 ${particle.size}px ui-monospace, SFMono-Regular, Menlo, Consolas, monospace`;
        ctx.fillStyle =
          particle.t < 0.48 ? "#74ffd7" : "#45f3bd";
        ctx.shadowColor = "rgba(61,255,195,.85)";
        ctx.shadowBlur = particle.t < 0.48 ? 7 : 12;
        ctx.fillText(
          particle.digit,
          -particle.size * 0.28,
          particle.size * 0.35
        );
        ctx.restore();
      }

      // Moving packets emphasize data movement.
      if (!reducedMotion) {
        for (let index = 0; index < 5; index += 1) {
          const progress =
            (time * 0.00022 + index / 5) % 1;

          const point =
            progress < 0.62
              ? bezier(
                  progress / 0.62,
                  brain,
                  [width * 0.52, height * 0.45],
                  [width * 0.58, height * 0.68],
                  hand
                )
              : bezier(
                  (progress - 0.62) / 0.38,
                  hand,
                  [width * 0.74, height * 0.74],
                  [width * 0.79, height * 0.63],
                  screen
                );

          ctx.save();
          ctx.fillStyle = "#a7ffe9";
          ctx.shadowColor = "#42f4bd";
          ctx.shadowBlur = 18;
          ctx.beginPath();
          ctx.arc(point.x, point.y, 3.6, 0, Math.PI * 2);
          ctx.fill();
          ctx.restore();
        }
      }

      animationFrame = window.requestAnimationFrame(draw);
    }

    const resizeObserver = new ResizeObserver(resize);

    resizeObserver.observe(canvas);
    resize();
    animationFrame = window.requestAnimationFrame(draw);

    return () => {
      window.cancelAnimationFrame(animationFrame);
      resizeObserver.disconnect();
    };
  }, []);

  return (
    <canvas
      ref={canvasRef}
      className="robot-motion-canvas"
      aria-hidden="true"
    />
  );
}