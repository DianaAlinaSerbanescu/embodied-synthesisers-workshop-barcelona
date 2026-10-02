import java.io.IOException;
import java.net.InetSocketAddress;
import java.net.SocketAddress;
import java.net.StandardProtocolFamily;
import java.nio.ByteBuffer;
import java.nio.channels.DatagramChannel;
import java.nio.charset.StandardCharsets;

// Ordinary Java tab: bypasses Processing's PDE parser for the Java API's open() method.
public final class WifiUdpReceiver {
  private final DatagramChannel channel;
  private final ByteBuffer buffer = ByteBuffer.allocate(512);

  public WifiUdpReceiver(int port) throws IOException {
    channel = DatagramChannel.open(StandardProtocolFamily.INET);
    try {
      channel.configureBlocking(false);
      channel.bind(new InetSocketAddress(port));
    } catch (IOException e) {
      channel.close();
      throw e;
    }
  }

  // null means no packet pending; empty array means an oversized packet.
  public String[] poll() throws IOException {
    buffer.clear();
    SocketAddress peer = channel.receive(buffer);
    if (peer == null) return null;
    if (buffer.position() >= buffer.capacity()) return new String[0];
    buffer.flip();
    return new String[] {
      StandardCharsets.US_ASCII.decode(buffer).toString(),
      ((InetSocketAddress) peer).getAddress().getHostAddress()
    };
  }

  public void close() throws IOException {
    channel.close();
  }
}
