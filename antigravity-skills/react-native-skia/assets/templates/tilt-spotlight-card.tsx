import React, { useMemo } from "react";
import {
  Canvas,
  Fill,
  Group,
  LinearGradient,
  RadialGradient,
  Rect,
  RoundedRect,
  Skia,
  vec,
} from "@shopify/react-native-skia";
import { Gesture, GestureDetector } from "react-native-gesture-handler";
import {
  clamp,
  useDerivedValue,
  useReducedMotion,
  useSharedValue,
  withSpring,
} from "react-native-reanimated";

const WIDTH = 320;
const HEIGHT = 200;
const RADIUS = 28;

export function TiltSpotlightCard() {
  const reduceMotion = useReducedMotion();
  const pointerX = useSharedValue(WIDTH / 2);
  const pointerY = useSharedValue(HEIGHT / 2);
  const tilt = useSharedValue(0);

  const spotlightCenter = useDerivedValue(() => ({
    x: pointerX.value,
    y: pointerY.value,
  }));

  const clip = useMemo(
    () => Skia.RRectXY(Skia.XYWHRect(0, 0, WIDTH, HEIGHT), RADIUS, RADIUS),
    []
  );

  const gesture = useMemo(
    () =>
      Gesture.Pan()
        .onChange((event) => {
          if (reduceMotion) {
            return;
          }

          pointerX.value = clamp(event.x, 40, WIDTH - 40);
          pointerY.value = clamp(event.y, 40, HEIGHT - 40);
          tilt.value = clamp((event.x - WIDTH / 2) / WIDTH, -0.12, 0.12);
        })
        .onFinalize(() => {
          pointerX.value = withSpring(WIDTH / 2);
          pointerY.value = withSpring(HEIGHT / 2);
          tilt.value = withSpring(0);
        }),
    [pointerX, pointerY, reduceMotion, tilt]
  );

  return (
    <GestureDetector gesture={gesture}>
      <Canvas style={{ width: WIDTH, height: HEIGHT }}>
        <Group
          clip={clip}
          origin={vec(WIDTH / 2, HEIGHT / 2)}
          transform={[{ rotate: tilt }]}
        >
          <Fill>
            <LinearGradient
              start={vec(0, 0)}
              end={vec(WIDTH, HEIGHT)}
              colors={["#07101F", "#1E3A8A", "#0B1220"]}
            />
          </Fill>

          <Rect x={0} y={0} width={WIDTH} height={HEIGHT}>
            <RadialGradient
              c={spotlightCenter}
              r={86}
              colors={[
                "rgba(255,255,255,0.24)",
                "rgba(255,255,255,0.08)",
                "rgba(255,255,255,0.0)",
              ]}
            />
          </Rect>

          <RoundedRect
            x={18}
            y={18}
            width={122}
            height={18}
            r={9}
            color="rgba(255,255,255,0.18)"
          />
          <RoundedRect
            x={18}
            y={48}
            width={166}
            height={12}
            r={6}
            color="rgba(255,255,255,0.12)"
          />
          <RoundedRect
            x={18}
            y={68}
            width={132}
            height={12}
            r={6}
            color="rgba(255,255,255,0.08)"
          />

          <RoundedRect
            x={1}
            y={1}
            width={WIDTH - 2}
            height={HEIGHT - 2}
            r={RADIUS - 1}
            style="stroke"
            strokeWidth={1}
            color="rgba(255,255,255,0.18)"
          />
        </Group>
      </Canvas>
    </GestureDetector>
  );
}
