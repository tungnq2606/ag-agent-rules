import React, { useMemo } from "react";
import {
  Atlas,
  Canvas,
  Circle,
  Group,
  useRSXformBuffer,
  useTexture,
  rect,
} from "@shopify/react-native-skia";
import { Gesture, GestureDetector } from "react-native-gesture-handler";
import { useReducedMotion, useSharedValue, withSpring } from "react-native-reanimated";

const WIDTH = 320;
const HEIGHT = 220;
const COUNT = 180;
const SPRITE = 18;

export function SpriteAtlasField() {
  const reduceMotion = useReducedMotion();
  const pointerX = useSharedValue(WIDTH / 2);
  const pointerY = useSharedValue(HEIGHT / 2);

  const texture = useTexture(
    <Group>
      <Circle cx={SPRITE / 2} cy={SPRITE / 2} r={SPRITE / 2 - 1} color="#22D3EE" />
      <Circle cx={SPRITE / 2 - 2} cy={SPRITE / 2 - 2} r={SPRITE / 5} color="#F8FAFC" />
    </Group>,
    { width: SPRITE, height: SPRITE }
  );

  const sprites = useMemo(
    () => new Array(COUNT).fill(0).map(() => rect(0, 0, SPRITE, SPRITE)),
    []
  );

  const transforms = useRSXformBuffer(COUNT, (value, index) => {
    "worklet";
    const columns = 18;
    const col = index % columns;
    const row = Math.floor(index / columns);
    const baseX = 8 + col * (SPRITE - 2);
    const baseY = 10 + row * (SPRITE - 2);
    const dx = pointerX.value - baseX;
    const dy = pointerY.value - baseY;
    const angle = Math.atan2(dy, dx);
    const scale = reduceMotion ? 1 : 0.9 + ((index % 5) * 0.03);
    value.set(scale * Math.cos(angle), scale * Math.sin(angle), baseX, baseY);
  });

  const gesture = useMemo(
    () =>
      Gesture.Pan()
        .onChange((event) => {
          pointerX.value = event.x;
          pointerY.value = event.y;
        })
        .onFinalize(() => {
          pointerX.value = withSpring(WIDTH / 2);
          pointerY.value = withSpring(HEIGHT / 2);
        }),
    [pointerX, pointerY]
  );

  return (
    <GestureDetector gesture={gesture}>
      <Canvas style={{ width: WIDTH, height: HEIGHT }}>
        <Atlas image={texture} sprites={sprites} transforms={transforms} />
      </Canvas>
    </GestureDetector>
  );
}
