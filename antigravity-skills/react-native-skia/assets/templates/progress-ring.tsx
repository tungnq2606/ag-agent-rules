import React, { useEffect, useMemo } from "react";
import {
  Canvas,
  Circle,
  Path,
  Skia,
  SweepGradient,
  vec,
} from "@shopify/react-native-skia";
import {
  useReducedMotion,
  useSharedValue,
  withTiming,
} from "react-native-reanimated";

type ProgressRingProps = {
  progress?: number; // 0..1
  size?: number;
  strokeWidth?: number;
};

export function ProgressRing({
  progress = 0.72,
  size = 220,
  strokeWidth = 18,
}: ProgressRingProps) {
  const reduceMotion = useReducedMotion();
  const end = useSharedValue(0);
  const radius = (size - strokeWidth) / 2;

  useEffect(() => {
    const clamped = Math.max(0, Math.min(1, progress));
    end.value = reduceMotion
      ? clamped
      : withTiming(clamped, { duration: 900 });
  }, [end, progress, reduceMotion]);

  const path = useMemo(() => {
    const ring = Skia.Path.Make();
    ring.addCircle(size / 2, size / 2, radius);
    return ring;
  }, [radius, size]);

  return (
    <Canvas style={{ width: size, height: size }}>
      <Circle
        cx={size / 2}
        cy={size / 2}
        r={radius}
        style="stroke"
        strokeWidth={strokeWidth}
        color="rgba(148, 163, 184, 0.18)"
      />

      <Path
        path={path}
        style="stroke"
        strokeWidth={strokeWidth}
        strokeCap="round"
        start={0}
        end={end}
      >
        <SweepGradient
          c={vec(size / 2, size / 2)}
          colors={["#22D3EE", "#60A5FA", "#8B5CF6", "#22D3EE"]}
        />
      </Path>
    </Canvas>
  );
}
