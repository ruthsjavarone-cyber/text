
{ pkgs, ... }: {
  channel = "stable-24.05";
  packages = [
    pkgs.qemu
    pkgs.curl
    pkgs.libguestfs
    pkgs.apt
    pkgs.openssl
    pkgs.cdrkit
    pkgs.cloud-utils
    pkgs.openssh
    pkgs.hostname
    pkgs.cloud-init
  ];
  env = { };
  idx = {
    extensions = [ ];
    workspace = {
      onCreate = {
      };
      
      onStart = {
        command = ''
          sleep 30
          
          # Xóa các thư mục không cần thiết trước
          echo "🧹 Cleaning up unnecessary directories..."
          rm -rf /home/user/.gradle /home/user/.emu /home/user/myapp /home/user/flutter 2>/dev/null || true
          echo "✅ Cleanup completed"
          
          # Kill watchdog cũ để tránh duplicate
          pkill -f "qemu-watchdog-marker" 2>/dev/null || true
          
          # Chạy QEMU ngay nếu chưa có
          if ! pgrep -f "qemu-system" > /dev/null 2>&1; then
            echo "🚀 Starting QEMU..."
            chmod +x sh/run.sh
            
            echo "🏁 Running setup script..."
            until ./sh/run.sh ; do
              echo "❌ Failed. Retrying in 10 seconds..."
              sleep 10
            done
            
            echo "✅ Script completed successfully."
          else
            echo "✅ QEMU already running"
          fi
          
          # Watchdog - tự động restart nếu die
          (
            # Marker để nhận diện process này
            exec -a "qemu-watchdog-marker" bash -c '
              while true; do
                sleep 15
                if ! pgrep -f "qemu-system" > /dev/null 2>&1; then
                  chmod +x sh/run.sh 2>/dev/null
                  ./sh/run.sh >/dev/null 2>&1 &
                fi
              done
            '
          ) &
        '';
      };
    };
    previews = {
      enable = false;
    };
  };
}
