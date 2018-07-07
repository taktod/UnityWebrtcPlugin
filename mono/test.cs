using System;
using System.Runtime.InteropServices;

public class Test {
  [DllImport("../Products/UnityWebrtcPlugin.bundle/Contents/MacOS/UnityWebrtcPlugin")]
  static extern void takWebrtc_make();
  [DllImport("../Products/UnityWebrtcPlugin.bundle/Contents/MacOS/UnityWebrtcPlugin")]
  static extern void takWebrtc_clean();
  [DllImport("../Products/UnityWebrtcPlugin.bundle/Contents/MacOS/UnityWebrtcPlugin")]
  static extern void takWebrtc_dispatchMain();
  static public void Main() {
    takWebrtc_make();
    takWebrtc_clean();
    Console.WriteLine("処理おわり");
  }
}