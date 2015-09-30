AppRTCDemo - A WebRTC for iOS Client Demo
=================================
![](AppRTCDemo.gif)

---
##About AppRTCDemo#
This is a WebRTC4iOS client demo. This demo show how 2 ios clients have a real-time audio&video communication. If you have the STUN/TURN server, they can communicate in different LAN.

---
##Requirements#
* Xcode 5 or higher
* iOS 6.0 or higher
* ARC

---
##About WebRTC#
[WebRTC](http://www.webrtc.org/home) is a free, open project that enables web browsers with Real-Time Communications (RTC) capabilities via simple JavaScript APIs. The WebRTC components have been optimized to best serve this purpose. 

---
##About WebRTC Native APIs and libjingle#
To implement real time communication, web developer can use WebRTC API, but we, as native developer, can use what? Thsese are: [WebRTC Native APIs](http://www.webrtc.org/reference/native-apis) and [libjingle](https://code.google.com/p/libjingle/source/browse/#svn%2Ftrunk%2Ftalk%2Fapp%2Fwebrtc), they can enable Native APP to implement RTC(Real-time communication) function.

In fact, the official has provided us some [Native Example Applications](https://code.google.com/p/webrtc/source/browse/#svn%2Ftrunk%2Ftalk%2Fexamples). Here is the [official iOS example](https://code.google.com/p/webrtc/source/browse/#svn%2Ftrunk%2Ftalk%2Fexamples%2Fios%2FAppRTCDemo%253Fstate%253Dclosed), but it's not good. This is a better [iOS example](https://github.com/gandg/webrtc-ios "gandg/webrtc-ios") based the official one.

---	
##About Signaling Service#
Signaling protocols and mechanisms are not defined by WebRTC standards, so you need to build it by yourself.

The demo uses XMPP to build the signaling service.It implements that with [XMPPFramework](https://github.com/robbiehanson/XMPPFramework).

PS: The [official iOS example](https://code.google.com/p/webrtc/source/browse/#svn%2Ftrunk%2Ftalk%2Fexamples%2Fios%2FAppRTCDemo%253Fstate%253Dclosed) uses the Google App Engine [Channel API](https://developers.google.com/appengine/docs/python/channel/?csw=1) to build the service.

---
##The Basic P2P Communication Process#
<table width="100%" border="1" bordercolor="#000000" bgcolor="#FFFFFF">
    <tbody>
        <tr>
            <td style="width:50%;text-align:center;">
                <strong><span style="font-size:18px;font-family:&#39;times new roman&#39;;">Caller</span></strong>
            </td>
            <td style="width:50%;text-align:center;">
                <strong><span style="font-size:18px;font-family:&#39;times new roman&#39;;">Callee</span></strong>
            </td>
        </tr>
        <tr>
            <td style="width:50%;">
                <p>
                    <span style="font-family:&#39;times new roman&#39;;font-size:14px;">1. build the signaling service and listen to the signaling message</span><br />
                </p>
            </td>
            <td style="width:50%;">
                <span style="font-family:&#39;times new roman&#39;;font-size:14px;background-color:#ffffff">1. build the signaling service and listen to the signaling message</span><br />
            </td>
        </tr>
        <tr>
            <td style="width:50%;text-align:center;" rowspan="1" colspan="2">
                <em><span style="font-size:14px;font-family:&#39;times new roman&#39;">... to bulid RTC connection...</span><br />
                </em>
            </td>
        </tr>
        <tr>
            <td style="width:50%;">
                <span style="font-family:&#39;times new roman&#39;;font-size:14px;background-color:#ffffff">2. create peerConnection</span><br />
            </td>
            <td style="width:50%;">
                <br />
            </td>
        </tr>
        <tr>
            <td style="width:50%;">
                <p>
                    <span style="font-family:&#39;times new roman&#39;;font-size:14px;background-color:#ffffff">3.1 create and send <strong>offer sdp</strong>(sessionDescription);</span>
                </p>
                <p>
                    <span style="font-family:&#39;times new roman&#39;;font-size:14px;background-color:#ffffff">      if got new  <strong>ICE Candidate</strong>, then send it to Callee</span>
                </p>
            </td>
            <td style="width:50%;">
                <span style="font-family:&#39;times new roman&#39;;font-size:14px;background-color:#ffffff">2. listen to the signaling message. Cache the remote offer sdp and ICE Candidate</span><br />
            </td>
        </tr>
        <tr>
            <td style="width:50%;">
                <br />
            </td>
            <td style="width:50%;">
                <span style="font-family:&#39;times new roman&#39;;font-size:14px;background-color:#ffffff">3.2 <span style="font-family:&#39;times new roman&#39;;font-size:14px;background-color:#ffffff">create peerConnection and deal with the <strong>offer sdp</strong> and </span><strong>ICE Can</strong><strong>didate</strong></span><br />
            </td>
        </tr>
        <tr>
            <td style="width:50%;">
                <span style="background-color:#ffffff;font-size:14px;font-family:&#39;times new roman&#39;">4.2 <span style="font-family:&#39;times new roman&#39;;font-size:14px;background-color:#ffffff">listen to the signaling message. Deal with the remote <strong>answer sdp</strong> and <strong>ICE Candidate</strong></span></span>
            </td>
            <td style="width:50%;">
                <p>
                    <span style="font-size:14px;font-family:&#39;times new roman&#39;">4.1 </span><span style="font-family:&#39;times new roman&#39;;font-size:14px;">create and send <strong>answer</strong></span><strong style="font-family:&#39;times new roman&#39;;font-size:14px;"> sdp</strong><span style="font-family:&#39;times new roman&#39;;font-size:14px;">(sessionDescription);</span>
                </p>
                <p>
                    <span style="font-family:&#39;times new roman&#39;;font-size:14px;background-color:#ffffff">      if got new  <strong>ICE Candidate</strong>, then send it to Caller</span>
                </p>
                <p>
                    <span style="font-size:14px;font-family:&#39;times new roman&#39;"></span>
                </p>
            </td>
        </tr>
        <tr>
            <td style="width:50%;text-align:center;" rowspan="1" colspan="2">
                <em><span style="font-family:&#39;times new roman&#39;;font-size:14px;background-color:#ffffff">..successfully building RTC connection, then can start audio and video communication...</span><br />
                </em>
            </td>
        </tr>
        <tr>
            <td style="width:50%;">
                <span style="font-size:14px;font-family:&#39;times new roman&#39;">5.1 send BYE signaling message and close </span><span style="font-family:&#39;times new roman&#39;;font-size:14px;background-color:#ffffff">peerConnection</span>
            </td>
            <td style="width:50%;">
                <span style="font-family:&#39;times new roman&#39;;font-size:14px;background-color:#ffffff">5.2 when get the BYE signaling message, then close peerConnection</span><br />
            </td>
        </tr>
    </tbody>
</table>
<p>
    <br />
</p>


**中文版**
<table width="100%" border="1" bordercolor="#000000" bgcolor="#FFFFFF">
    <tbody>
        <tr>
            <td style="width:50%;text-align:center;">
                <strong><span style="font-size:18px;font-family:&#39;times new roman&#39;;">Caller</span></strong>
            </td>
            <td style="width:50%;text-align:center;">
                <strong><span style="font-size:18px;font-family:&#39;times new roman&#39;;">Callee</span></strong>
            </td>
        </tr>
        <tr>
            <td style="width:50%;">
                <span style="font-family:&#39;times new roman&#39;;font-size:14px;background-color:#ffffff">1. 建立信令通讯(XMPPWorker)以及监听信令</span><br />
            </td>
            <td style="width:50%;">
                <span style="font-family:&#39;times new roman&#39;;font-size:14px;background-color:#ffffff">1. </span><span style="font-family:&#39;times new roman&#39;;font-size:14px;background-color:#ffffff">建立信令通讯(XMPPWorker)以及监听信令</span><br />
            </td>
        </tr>
        <tr>
            <td style="width:50%;text-align:center;" rowspan="1" colspan="2">
                <em><span style="font-size:14px;font-family:&#39;times new roman&#39;">... 建立RTC 链接...</span><br />
                </em>
            </td>
        </tr>
        <tr>
            <td style="width:50%;">
                <span style="font-family:&#39;times new roman&#39;;font-size:14px;background-color:#ffffff">2. 创建 peerConnection</span><br />
            </td>
            <td style="width:50%;">
                <br />
            </td>
        </tr>
        <tr>
            <td style="width:50%;">
                <p>
                    <span style="font-family:&#39;times new roman&#39;;font-size:14px;background-color:#ffffff">3.1 创建并发送 <strong>offer</strong>；</span>
                </p>
                <p>
                    <span style="font-family:&#39;times new roman&#39;;font-size:14px;background-color:#ffffff">      若发现新的<strong>ICE Candidate</strong>，则发送给Callee</span>
                </p>
            </td>
            <td style="width:50%;">
                <span style="font-family:&#39;times new roman&#39;;font-size:14px;background-color:#ffffff">2. 监听信令。把收到的 <strong>offer</strong> 以及 <strong>ICE Candidate</strong>缓存起来</span><br />
            </td>
        </tr>
        <tr>
            <td style="width:50%;">
                <br />
            </td>
            <td style="width:50%;">
                <span style="font-family:&#39;times new roman&#39;;font-size:14px;background-color:#ffffff">3.2 创建 peerConnection，处理缓存的 <strong>offer</strong> 以及<strong>ICE Candidate</strong></span><br />
            </td>
        </tr>
        <tr>
            <td style="width:50%;">
                <span style="background-color:#ffffff;font-size:14px;font-family:&#39;times new roman&#39;">4.2 监听</span><span style="font-family:&#39;times new roman&#39;;font-size:14px;background-color:#ffffff">信令。直接处理收到的 <strong>answer</strong> 以及 <strong>ICE Candidate</strong></span>
            </td>
            <td style="width:50%;">
                <p>
                    <span style="font-size:14px;font-family:&#39;times new roman&#39;">4.1 </span><span style="font-family:&#39;times new roman&#39;;font-size:14px;background-color:#ffffff">创建并发送 <strong>answer</strong></span><span style="font-family:&#39;times new roman&#39;;font-size:14px">；</span>
                </p>
                <p>
                    <span style="font-family:&#39;times new roman&#39;;font-size:14px">      <span style="font-family:&#39;times new roman&#39;;font-size:14px;background-color:#ffffff">若发现新的</span><strong><span style="font-family:&#39;times new roman&#39;;font-size:14px;background-color:#ffffff">ICE C</span><span style="font-family:&#39;times new roman&#39;;font-size:14px;background-color:#ffffff">andidate</span></strong><span style="font-family:&#39;times new roman&#39;;font-size:14px;background-color:#ffffff">，则发送给Caller</span></span>
                </p>
            </td>
        </tr>
        <tr>
            <td style="width:50%;text-align:center;" rowspan="1" colspan="2">
                <em><span style="font-family:&#39;times new roman&#39;;font-size:14px;background-color:#ffffff">..RTC 链接建立完毕，开始进行音视频通讯...</span><br />
                </em>
            </td>
        </tr>
        <tr>
            <td style="width:50%;">
                <span style="font-size:14px;font-family:&#39;times new roman&#39;">5.1 </span><span style="font-family:&#39;times new roman&#39;;font-size:14px;background-color:#ffffff">发送  BYE 信令，关闭 peerConnection</span>
            </td>
            <td style="width:50%;">
                <span style="font-family:&#39;times new roman&#39;;font-size:14px;background-color:#ffffff">5.2 收到 BYE 信令后，关闭 peerConnection</span><br />
            </td>
        </tr>
    </tbody>
</table>
<p>
    <br />
</p>

---
##100% Attention#
* In this demo, I custom-make a `signaling` type XMPPMessage to transfer the signallings. **Before run this demo, Please Check whether your jabber server can support this custom XMPPMessage.** If your jabber server cann't support it, you should modify the custom XMPPMessage's type that your jabber server can support in the `XMPPMessage+Signaling` file, for example in the file change `TYPE_SIGNALING` macro value `signaling` to `chat`.

* 在该Demo中，我使用的是自定义的、类型为 `signaling` 的 XMPPMessage 来传递信令。**运行该Demo前，请务必检测你的jabber服务器是否支持这种自定义类型的 XMPPMessage 。**如果不支持，请把该类型的 XMPPMessage 修改为你的jabber服务器支持的类型，如 `chat` 类型（在`XMPPMessage+Signaling`文件中修改`TYPE_SIGNALING`的宏定义值即可）。

---
##Change Log#

#### 1.0 - 2014/03/11

* Initial release. Now 2 iOS client can have a real-time audio&video communication repeatedly, and if you have the STUN/TURN server, they can communicate each other in different LAN.


