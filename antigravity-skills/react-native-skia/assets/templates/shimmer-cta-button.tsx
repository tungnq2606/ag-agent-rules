import React, { useEffect, useMemo } from "react";
import {
  Canvas,
  Fill,
  Group,
  LinearGradient,
  Paragraph,
  Rect,
  RoundedRect,
  Skia,
  TextAlign,
  vec,
} from "@shopify/react-native-skia";
import {
  Easing,
  useReducedMotion,
  useSharedValue,
  withRepeat,
  withTiming,
} from "react-native-reanimated";

const WIDTH = 280;
const HEIGHT = 64;
const RADIUS = 20;

export function ShimmerCTAButton() {
  const reduceMotion = useReducedMotion();
  const shimmerX = useSharedValue(-100);

  useEffect(() => {
    if (reduceMotion) {
      shimmerX.value = WIDTH * 0.4;
      return;
    }

    shimmerX.value = withRepeat(
      withTiming(WIDTH + 100, {
        duration: 1800,
        easing: Easing.linear,
      }),
      -1,
      false
    );
  }, [reduceMotion, shimmerX]);

  const clip = useMemo(
    () => Skia.RRectXY(Skia.XYWHRect(0, 0, WIDTH, HEIGHT), RADIUS, RADIUS),
    []
  );

  const label = useMemo(() => {
    const paragraph = Skia.ParagraphBuilder.Make({ textAlign: TextAlign.Center })
      .pushStyle({
        color: Skia.Color("#F8FAFC"),
        fontSize: 18,
        fontStyle: { weight: 500 },
      })
      .addText("Upgrade now")
      .pop()
      .build();

    paragraph.layout(WIDTH);
    return paragraph;
  }, []);

  return (
    <Canvas style={{ width: WIDTH, height: HEIGHT }}>
      <Group clip={clip}>
        <Fill>
          <LinearGradient
            start={vec(0, 0)}
            end={vec(WIDTH, HEIGHT)}
            colors={["#1D4ED8", "#2563EB", "#7C3AED"]}
          />
        </Fill>

        <RoundedRect
          x={0}
          y={0}
          width={WIDTH}
          height={HEIGHT}
          r={RADIUS}
          color="rgba(255,255,255,0.04)"
        />

        <Group transform={[{ translateX: shimmerX }, { rotate: -0.22 }]}>
          <Rect x={0} y={-48} width={70} height={HEIGHT + 96}>
            <LinearGradient
              start={vec(0, 0)}
              end={vec(70, 0)}
              colors={[
                "rgba(255,255,255,0.0)",
                "rgba(255,255,255,0.28)",
                "rgba(255,255,255,0.0)",
              ]}
            />
          </Rect>
        </Group>

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

      <Paragraph paragraph={label} x={0} y={20} width={WIDTH} />
    </Canvas>
  );
}
