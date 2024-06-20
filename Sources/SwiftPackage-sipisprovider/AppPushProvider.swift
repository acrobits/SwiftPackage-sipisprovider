//
//  AppPushProvider.swift
//  networkExt
//
//  Created by Stanislav Kutil on 09.06.2021.
//

import Foundation
import NetworkExtension

/*
 * we suggest having the app push extension in an app group so the main app can access the sipis.log and
 * the app can share the encryption key with the extension via the keychain
 * here the app group identifier is stored in main app's bundle info.plist as SHARED_APP_GROUP_ID
 * the encryption key is used for encrypting the SIP account data coming from the app to the extension via HTTP
 * and to encypt the extension's sqlite DB. We stongly suggest using one
 * either by storing the key (16 bytes) into the keychain where both the SDK (app) and the extension can see it (service "key", account "sipis"),
 * or by putting it in the SDK's preference key named `localSipisCommProtectionKey` and getting the same key to the extension by any other means
 *
 * to configure the SDK to use local sipis the easiest way is to set the `incomingCallsMode` pref key to `localPush`
 * or set the `icm` property of an account to `localPush`
 */

@objc(AppPushProvider)
public class AppPushProvider: NEAppPushProvider {
        
    public var _sipis: LocalSipis?
    public var _log: NSLogSerializer? = NSLogSerializer(prefix: "AppPushProvider")

    public override init() {
        super.init()
        
        _sipis = LocalSipis(notificationHandler: SipisNotificationHandler(witProvider: self))
        _sipis?.setCustomSink(_log)
    }
    
    public override func start(completionHandler: @escaping (Error?) -> Void)
    {
        NSLog("AppPushProvider:    starting network extension (%@)", self);
        DispatchQueue.main.async { [self] in
            
            let basePath = sharedPath(filename: nil)!       // shared directory path
            let key : Data? = sharedKey();                  // it should be a random 16 bytes encryption key (preferably stored in the keychain)
            
            let postDataArray:[String]? = self.providerConfiguration?["postData"] as! [String]?;

            let strSettings = """
                
                <Sipis>
                  <Server Name="local sipis" Address="0.0.0.0" Port="4998" PublicAddress="107.170.123.70"/>
                  <HttpServer Address="0.0.0.0" Port="5000"/>
                  <Lock FileName="{BASEPATH}/sipis.pid"/>
                  <Administrator UserName="admin" Password="admin"/>
                  <Database OpenString="{BASEPATH}/sipisdb.sqlite"/>
                  <Log FileName="{BASEPATH}/sipis.log" Format="PlainText" InstanceFileName="{BASEPATH}/$SELECTOR$.log" Level="Debug" Stdio="Warning" InstanceFormat="PlainText">
                    <Instance Selector="*">
                      <StopOn Year="2100" Month="1" Day="1"/>
                    </Instance>
                    <Http RequestBody="Yes" />
                  </Log>
                  <TlsClientCertificates>
                    <!--
                    <Certificate
                        Host=""
                        FileName=""
                        RsaPrivateKeyFileName=""/>
                    -->
                  </TlsClientCertificates>
                  <Instance UserAgent="Local Push">
                    <MaxAge Days="365"/>
                    <PremiumMaxAge Days="365"/>
                    <NotRegisteredMaxAge Minutes="3"/>
                    <KeepAlivePackets Enabled="Yes">
                       <Period Seconds="60"/>
                    </KeepAlivePackets>
                    <AboutToExpireIn Minutes="4">
                    <Silent Minutes="1"/>
                    </AboutToExpireIn>
                    <AboutToExpirePeriod Minutes="2">
                        <Silent Minutes="2"/>
                   </AboutToExpirePeriod>
                  </Instance>
                  <IncomingCall>
                    <NotAnsweredMaxAge Days="0" Hours="0" Minutes="2" Seconds="0"/>
                  </IncomingCall>
                  <IncomingTextMessage>
                    <Filter>
                      <Entry Action="AcceptAndDrop" Enabled="Yes">
                        <Header Name="Content-Type" Equal="application/im-iscomposing+xml" />
                      </Entry>
                      <Entry Action="AcceptAndDoNotPush" Enabled="Yes">
                        <Header Name="Content-Type" Contains=";imdn" />
                      </Entry>
                      <Entry Action="Reject" Enabled="Yes">
                        <Header Name="Content-Length" UintGt="4194304" />
                        <RejectWith Code="413" Phrase="Request Entity Too Large" />
                      </Entry>
                    </Filter>
                  </IncomingTextMessage>
                </Sipis>
                """

            _sipis?.start(withSettings: strSettings, basePath: basePath, key: key, completionHandler: { (error: Error?) -> Void in
                postDataArray?.forEach({ postData in
                    self._sipis?.registerAccount(withPostData: postData, encrypted: key?.count ?? 0 > 0)
                })
                NSLog("AppPushProvider:    starting local sipis finished");
                completionHandler(error)
            })
        }
        
    }

    public override func stop(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        DispatchQueue.main.async { [self] in
            let option : StopOptionType = StopOption_ForgetInstances
            
//            switch reason {
//            case .providerDisabled,
//                    .configurationFailed,
//                    .configurationDisabled,
//                    .configurationRemoved,
//                    .superceded
//                :
//                option = StopOption_ForgetInstances
//            default:
//                option = StopOption_RememberInstances
//            }
            _sipis?.stop(with:option, completionHandler: completionHandler)
        }
    }
    
    public override func handleTimerEvent() {
        DispatchQueue.main.async { [self] in
            _sipis?.timerEvent()
        }
    }
    
    /*
     helper function to get the shared app group ID from the app's Info.plist SHARED_APP_GROUP_ID
     and builing a path to the shared directory
     */
    public func sharedPath(filename: String?) -> String?
    {
        let shareGroupIdentifier = Bundle.sharedAppGroupId();
        
        if shareGroupIdentifier == nil
        {
            return nil
        }
        let appGroupFolderUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: shareGroupIdentifier!)
        
        if appGroupFolderUrl == nil
        {
            return nil
        }
        
        if filename == nil
        {
            return appGroupFolderUrl!.path
        } else
        {
            return appGroupFolderUrl!.appendingPathComponent(filename!).path
        }
    }
    
    public func sharedKey() -> Data?
    {
        let keychainItemQuery = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: "key",
            kSecAttrAccount: "sipis",
            kSecMatchLimit: kSecMatchLimitOne,
            kSecReturnAttributes: true,
            kSecReturnData: true,
        ] as CFDictionary
        
        var result: AnyObject?
        
        let status = SecItemCopyMatching(keychainItemQuery, &result)
        
        if status == noErr
        {
            let dic = result as! NSDictionary
            
            return dic[kSecValueData] as? Data
            
        } else
        {
            return nil
        }
    }
}
