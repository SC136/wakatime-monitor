using System;
using System.Threading;
using System.Windows.Forms;
class WindowFixture {
  [System.Runtime.InteropServices.DllImport("user32.dll")] static extern bool ShowWindow(IntPtr h, int n);
  [STAThread] static void Main() {
    var form = new Form { Text = "WakaTime monitor verification", Width = 360, Height = 100 };
    var timer = new System.Windows.Forms.Timer { Interval = 5000 };
    int tick = 0;
    timer.Tick += delegate { if (++tick == 1) form.WindowState = FormWindowState.Minimized; else form.Close(); };
    form.Shown += delegate { ShowWindow(form.Handle, 5); };
    timer.Start();
    Application.Run(form);
    timer.Dispose();
    Thread.Sleep(15000);
  }
}

