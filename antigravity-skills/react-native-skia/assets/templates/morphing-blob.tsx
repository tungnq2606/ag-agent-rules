import React, { useEffect } from "react";
import {
  Blur,
  Canvas,
  Fill,
  Group,
  LinearGradient,
  Paint,
  Path,
  Skia,
  usePathInterpolation,
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
const HEIGHT = 280;

const PATH_A = Skia.Path.MakeFromSVGString(
  "M140 26C183 26 223 57 234 103C246 153 220 214 170 241C118 269 58 249 33 203C7 155 19 95 58 58C80 37 109 26 140 26Z"
)!;
const PATH_B = Skia.Path.MakeFromSVGString(
  "M143 26C191 31 231 66 239 113C246 156 221 215 171 242C120 270 58 250 31 201C9 160 19 104 51 66C73 40 106 22 143 26Z"
)!;
const PATH_C = Skia.Path.MakeFromSVGString(
  "M139 29C189 24 232 63 241 111C250 156 218 219 165 244C109 270 44 242 26 190C11 148 31 102 64 65C83 43 110 32 139 29Z"
)!;

export function MorphingBlob() {
  const reduceMotion = useReducedMotion();
  const progress = useSharedValue(0.4);

  useEffect(() => {
    if (reduceMotion) {
      progress.value = 0.5;
      return;
    }

    progress.value = withRepeat(
      withTiming(2, {
        duration: 4200,
        easing: Easing.inOut(Easing.cubic),
      }),
      -1,
      true
    );
  }, [progress, reduceMotion]);

  const path = usePathInterpolation(progress, [0, 1, 2], [PATH_A, PATH_B, PATH_C]);

  return (
    <Canvas style={{ width: WIDTH, height: HEIGHT }}>
      <Fill color="#040816" />

      <Group transform={[{ translateX: 6 }, { translateY: 8 }]}>
        <Group layer={<Paint><Blur blur={24} /></Paint>}>
          <Path path={path} color="rgba(96,165,250,0.28)" />
        </Group>

        <Path path={path}>
          <LinearGradient
            start={vec(40, 30)}
            end={vec(220, 250)}
            colors={["#60A5FA", "#8B5CF6", "#22D3EE"]}
          />
        </Path>
      </Group>
    </Canvas>
  );
}
