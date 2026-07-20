import React, { useRef, useState } from "react";
import { Pressable, StyleSheet, Text, View } from "react-native";
import {
  Canvas,
  Image,
  RoundedRect,
  type SkImage,
  makeImageFromView,
} from "@shopify/react-native-skia";

export function SnapshotComposite() {
  const ref = useRef<View>(null);
  const [snapshot, setSnapshot] = useState<SkImage | null>(null);

  const capture = async () => {
    const image = await makeImageFromView(ref);
    setSnapshot(image);
  };

  return (
    <View>
      <View ref={ref} collapsable={false} style={styles.card}>
        <Text style={styles.title}>Snapshot this card</Text>
        <Text style={styles.body}>
          Capture a React Native subtree and then reuse it inside Skia.
        </Text>
      </View>

      <Pressable onPress={capture} style={styles.button}>
        <Text style={styles.buttonText}>Capture</Text>
      </Pressable>

      {snapshot ? (
        <Canvas style={styles.canvas}>
          <RoundedRect x={0} y={0} width={320} height={180} r={28} color="#0F172A" />
          <RoundedRect
            x={1}
            y={1}
            width={318}
            height={178}
            r={27}
            style="stroke"
            strokeWidth={1}
            color="rgba(255,255,255,0.10)"
          />
          <Image image={snapshot} x={16} y={16} width={288} height={148} fit="contain" />
        </Canvas>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    borderRadius: 24,
    padding: 18,
    backgroundColor: "#0F172A",
  },
  title: {
    color: "#F8FAFC",
    fontSize: 18,
    fontWeight: "600",
  },
  body: {
    color: "#CBD5E1",
    fontSize: 14,
    marginTop: 8,
    lineHeight: 20,
  },
  button: {
    marginTop: 12,
    alignSelf: "flex-start",
    borderRadius: 16,
    paddingHorizontal: 14,
    paddingVertical: 10,
    backgroundColor: "#1D4ED8",
  },
  buttonText: {
    color: "#F8FAFC",
    fontWeight: "600",
  },
  canvas: {
    width: 320,
    height: 180,
    marginTop: 16,
  },
});
