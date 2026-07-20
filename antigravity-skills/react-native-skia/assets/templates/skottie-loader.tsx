import React, { useMemo } from "react";
import {
  Blur,
  Canvas,
  Group,
  Paint,
  Skia,
  Skottie,
  useClock,
} from "@shopify/react-native-skia";
import { useDerivedValue, useReducedMotion } from "react-native-reanimated";

type SkottieLoaderProps = {
  animationJson: Record<string, unknown>;
  width?: number;
  height?: number;
  accentColor?: string;
};

/**
 * Pass the parsed JSON object from a bundled Lottie file:
 *
 * const loaderJson = require("../assets/loader.json");
 * <SkottieLoader animationJson={loaderJson} accentColor="#60A5FA" />
 */
export function SkottieLoader({
  animationJson,
  width = 220,
  height = 220,
  accentColor,
}: SkottieLoaderProps) {
  const animation = useMemo(() => {
    const value = Skia.Skottie.Make(JSON.stringify(animationJson));
    if (!value) {
      throw new Error("Failed to create Skottie animation from JSON.");
    }

    if (accentColor) {
      const slotInfo = value.getSlotInfo();
      if (slotInfo.colorSlotIDs.length > 0) {
        value.setColorSlot(slotInfo.colorSlotIDs[0], Skia.Color(accentColor));
      }
    }

    return value;
  }, [accentColor, animationJson]);

  const reduceMotion = useReducedMotion();
  const clock = useClock();

  const frame = useDerivedValue(() => {
    if (reduceMotion) {
      return 0;
    }

    const fps = animation.fps();
    const duration = animation.duration();
    return Math.floor((clock.value / 1000) * fps) % Math.max(1, duration * fps);
  });

  const size = animation.size();
  const fitScale = Math.min(width / size.width, height / size.height);
  const offsetX = (width - size.width * fitScale) / 2;
  const offsetY = (height - size.height * fitScale) / 2;

  return (
    <Canvas style={{ width, height }}>
      <Group
        layer={
          <Paint>
            <Blur blur={4} />
          </Paint>
        }
        transform={[
          { translateX: offsetX },
          { translateY: offsetY },
          { scale: fitScale },
        ]}
      >
        <Skottie animation={animation} frame={frame} />
      </Group>
    </Canvas>
  );
}
