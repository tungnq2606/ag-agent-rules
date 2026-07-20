import React, { useEffect, useMemo } from "react";
import {
  Blur,
  Canvas,
  Circle,
  Fill,
  Group,
  LinearGradient,
  Paint,
  RoundedRect,
  Skia,
  vec,
} from "@shopify/react-native-skia";
import {
  Easing,
  useDerivedValue,
  useReducedMotion,
  useSharedValue,
  withRepeat,
  withTiming,
} from "react-native-reanimated";

const WIDTH = 320;
const HEIGHT = 200;
const RADIUS = 28;

export function AmbientGradientCard() {
  const reduceMotion = useReducedMotion();
  const progress = useSharedValue(0.35);

  useEffect(() => {
    if (reduceMotion) {
      progress.value = 0.35;
      return;
    }

    progress.value = withRepeat(
      withTiming(1, {
        duration: 5200,
        easing: Easing.inOut(Easing.sin),
      }),
      -1,
      true
    );
  }, [progress, reduceMotion]);

  const orbAX = useDerivedValue(() => 70 + progress.value * 90);
  const orbAY = useDerivedValue(() => 62 + Math.sin(progress.value * Math.PI) * 26);

  const orbBX = useDerivedValue(() => 240 - progress.value * 80);
  const orbBY = useDerivedValue(() => 138 - Math.cos(progress.value * Math.PI) * 22);

  const orbCX = useDerivedValue(() => 180 + Math.sin(progress.value * Math.PI * 2) * 28);
  const orbCY = useDerivedValue(() => 54 + Math.cos(progress.value * Math.PI * 2) * 18);

  const clip = useMemo(
    () => Skia.RRectXY(Skia.XYWHRect(0, 0, WIDTH, HEIGHT), RADIUS, RADIUS),
    []
  );

  return (
    <Canvas style={{ width: WIDTH, height: HEIGHT }}>
      <Group clip={clip}>
        <Fill>
          <LinearGradient
            start={vec(0, 0)}
            end={vec(WIDTH, HEIGHT)}
            colors={["#07101F", "#11284C", "#090F1C"]}
          />
        </Fill>

        <Group layer={<Paint><Blur blur={38} /></Paint>}>
          <Circle cx={orbAX} cy={orbAY} r={74} color="rgba(96, 165, 250, 0.55)" />
          <Circle cx={orbBX} cy={orbBY} r={78} color="rgba(168, 85, 247, 0.40)" />
          <Circle cx={orbCX} cy={orbCY} r={52} color="rgba(34, 211, 238, 0.32)" />
        </Group>

        <RoundedRect
          x={0}
          y={0}
          width={WIDTH}
          height={HEIGHT}
          r={RADIUS}
          color="rgba(255,255,255,0.035)"
        />
        <RoundedRect
          x={1}
          y={1}
          width={WIDTH - 2}
          height={HEIGHT - 2}
          r={RADIUS - 1}
          style="stroke"
          strokeWidth={1}
          color="rgba(255,255,255,0.12)"
        />

        <RoundedRect
          x={18}
          y={18}
          width={132}
          height={18}
          r={9}
          color="rgba(255,255,255,0.18)"
        />
        <RoundedRect
          x={18}
          y={48}
          width={182}
          height={12}
          r={6}
          color="rgba(255,255,255,0.12)"
        />
        <RoundedRect
          x={18}
          y={68}
          width={148}
          height={12}
          r={6}
          color="rgba(255,255,255,0.09)"
        />

        <RoundedRect
          x={18}
          y={HEIGHT - 54}
          width={110}
          height={30}
          r={15}
          color="rgba(255,255,255,0.10)"
        />
      </Group>
    </Canvas>
  );
}
