import React from "react";
import { Pressable } from "react-native";
import {
  Canvas,
  ColorMatrix,
  Fill,
  ImageShader,
  RoundedRect,
  useVideo,
} from "@shopify/react-native-skia";
import { useSharedValue } from "react-native-reanimated";

type VideoFrameSurfaceProps = {
  source: string | number;
  width?: number;
  height?: number;
  pausedInitially?: boolean;
};

/**
 * Notes:
 * - React Native Skia video needs Reanimated v3+.
 * - Android video support requires API 26+.
 * - For Expo assets, resolve the bundled URI first if needed.
 */
export function VideoFrameSurface({
  source,
  width = 320,
  height = 220,
  pausedInitially = false,
}: VideoFrameSurfaceProps) {
  const paused = useSharedValue(pausedInitially);
  const { currentFrame } = useVideo(source, {
    paused,
    looping: true,
  });

  return (
    <Pressable
      onPress={() => {
        paused.value = !paused.value;
      }}
      style={{ width, height }}
    >
      <Canvas style={{ width, height }}>
        {currentFrame ? (
          <Fill>
            <ImageShader
              image={currentFrame}
              x={0}
              y={0}
              width={width}
              height={height}
              fit="cover"
            />
            <ColorMatrix
              matrix={[
                0.95, 0, 0, 0, 0.05,
                0.70, 0, 0, 0, 0.12,
                0.18, 0, 0, 0, 0.42,
                0, 0, 0, 1, 0,
              ]}
            />
          </Fill>
        ) : null}

        <RoundedRect
          x={1}
          y={1}
          width={width - 2}
          height={height - 2}
          r={26}
          style="stroke"
          strokeWidth={1}
          color="rgba(255,255,255,0.14)"
        />
      </Canvas>
    </Pressable>
  );
}
