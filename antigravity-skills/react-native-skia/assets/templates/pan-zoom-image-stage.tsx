import React, { useMemo } from "react";
import { PixelRatio } from "react-native";
import { Canvas, Group, Image, useImage, vec } from "@shopify/react-native-skia";
import { Gesture, GestureDetector } from "react-native-gesture-handler";
import { clamp, useSharedValue } from "react-native-reanimated";

type PanZoomImageStageProps = {
  source: number | string;
  width?: number;
  height?: number;
  minScale?: number;
  maxScale?: number;
};

export function PanZoomImageStage({
  source,
  width = 320,
  height = 220,
  minScale = 1,
  maxScale = 4,
}: PanZoomImageStageProps) {
  const image = useImage(source);
  const translateX = useSharedValue(0);
  const translateY = useSharedValue(0);
  const scale = useSharedValue(1);
  const baseScale = useSharedValue(1);

  const pan = useMemo(
    () =>
      Gesture.Pan().onChange((event) => {
        translateX.value += event.changeX;
        translateY.value += event.changeY;
      }),
    [translateX, translateY]
  );

  const pinch = useMemo(
    () =>
      Gesture.Pinch()
        .onChange((event) => {
          scale.value = clamp(baseScale.value * event.scale, minScale, maxScale);
        })
        .onEnd(() => {
          baseScale.value = scale.value;
        }),
    [baseScale, maxScale, minScale, scale]
  );

  const gesture = useMemo(() => Gesture.Simultaneous(pan, pinch), [pan, pinch]);

  if (!image) {
    return null;
  }

  const pd = PixelRatio.get();
  const imageWidth = image.width() / pd;
  const imageHeight = image.height() / pd;

  return (
    <GestureDetector gesture={gesture}>
      <Canvas style={{ width, height }}>
        <Group
          origin={vec(width / 2, height / 2)}
          transform={[
            { translateX },
            { translateY },
            { scale },
          ]}
        >
          <Image
            image={image}
            x={(width - imageWidth) / 2}
            y={(height - imageHeight) / 2}
            width={imageWidth}
            height={imageHeight}
            fit="cover"
          />
        </Group>
      </Canvas>
    </GestureDetector>
  );
}
