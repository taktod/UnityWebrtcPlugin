using System;
using System.Runtime.InteropServices;

public class Test {
  [DllImport("../Products/UnityWebrtcPlugin.bundle/Contents/MacOS/UnityWebrtcPlugin")]
  static extern void test();
  static public void Main() {
    test();
  }
}