import React, { useMemo } from "react";
import {
  Canvas,
  Paragraph,
  RoundedRect,
  Skia,
  TextAlign,
  useFonts,
} from "@shopify/react-native-skia";

type CustomFontParagraphBadgeProps = {
  fontFamily: string;
  fontFiles: Record<string, number[]>;
  title?: string;
  body?: string;
  width?: number;
};

/**
 * Example:
 *
 * <CustomFontParagraphBadge
 *   fontFamily="Inter"
 *   fontFiles={{
 *     Inter: [
 *       require("../assets/fonts/Inter-Regular.ttf"),
 *       require("../assets/fonts/Inter-SemiBold.ttf"),
 *     ],
 *   }}
 * />
 */
export function CustomFontParagraphBadge({
  fontFamily,
  fontFiles,
  title = "Skia badge",
  body = "Wrapped, multi-style text with an explicit custom font family.",
  width = 300,
}: CustomFontParagraphBadgeProps) {
  const fontManager = useFonts(fontFiles);

  const paragraph = useMemo(() => {
    if (!fontManager) {
      return null;
    }

    const contentWidth = width - 32;
    const builder = Skia.ParagraphBuilder.Make(
      { textAlign: TextAlign.Left, maxLines: 3 },
      fontManager
    );

    builder
      .pushStyle({
        color: Skia.Color("#F8FAFC"),
        fontFamilies: [fontFamily],
        fontSize: 18,
        fontStyle: { weight: 500 },
      })
      .addText(`${title}\n`)
      .pop()
      .pushStyle({
        color: Skia.Color("#CBD5E1"),
        fontFamilies: [fontFamily],
        fontSize: 13,
        heightMultiplier: 1.2,
      })
      .addText(body)
      .pop();

    const result = builder.build();
    result.layout(contentWidth);
    return result;
  }, [body, fontFamily, fontManager, title, width]);

  if (!paragraph) {
    return null;
  }

  return (
    <Canvas style={{ width, height: 120 }}>
      <RoundedRect x={0} y={0} width={width} height={120} r={22} color="#0F172A" />
      <RoundedRect
        x={1}
        y={1}
        width={width - 2}
        height={118}
        r={21}
        style="stroke"
        strokeWidth={1}
        color="rgba(255,255,255,0.10)"
      />
      <Paragraph paragraph={paragraph} x={16} y={16} width={width - 32} />
    </Canvas>
  );
}
