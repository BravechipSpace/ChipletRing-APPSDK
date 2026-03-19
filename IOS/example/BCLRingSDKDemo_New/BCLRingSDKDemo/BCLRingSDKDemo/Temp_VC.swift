//
//  Temp_VC.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2026/1/30.
//

import BCLRingSDK
import SnapKit
import UIKit

class Temp_VC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        readFirmwareVersion()
    }

    // MARK: - Firmware Version and Upgrade

    /// Retrieve firmware version and check/execute upgrade (Z5I: use the stronger version number, otherwise use the current version)
    func readFirmwareVersion() {
        BCLRingManager.shared.readFirmware { [weak self] res in
            switch res {
            case let .success(response):
                BDLogger.info("Firmware version: \(response.firmwareVersion)")

                guard !response.firmwareVersion.isEmpty else {
                    BDLogger.error("Firmware version is empty")
                    return
                }

                let checkVersion = response.firmwareVersion.hasSuffix("Z5I")
                    ? response.firmwareVersion
                    : "7.2.9.0Z5I"

                if response.firmwareVersion.hasSuffix("Z5I") {
                    BDLogger.info("Firmware versions ending in Z5I Firmware versions not ending in Z5I Follow standard logic")
                } else {
                    BDLogger.info("The firmware version does not end with Z5I, triggering the forced flash logic.")
                    
                }
                
                // If the current user's ring firmware version is Z5I, it is possible to directly verify whether the current firmware version is the latest. If not, the latest firmware version can be obtained for download and OTA upgrade.
                // If the current user's ring firmware version is not Z5I, pass in a lower Z5I firmware version such as "7.2.0Z5I". This will reliably retrieve the latest Z5I firmware version, then download the firmware and execute the OTA upgrade, thereby flashing the device back to the Z5I firmware.9If the current user's ring firmware version is not Z5I, pass in a lower Z5I firmware version such as "7.2.0Z5I". This will reliably retrieve the latest Z5I firmware version, then download the firmware and execute the OTA upgrade, thereby flashing the device back to the Z5I firmware.
                self?.checkAndPerformFirmwareUpdate(version: checkVersion)

            case let .failure(error):
                BDLogger.error("Failed to read firmware version: \(error)")
            }
        }
    }

    /// Check for firmware updates; if a new version is available, download and execute the Apollo upgrade.
    private func checkAndPerformFirmwareUpdate(version: String) {
        BCLRingManager.shared.checkFirmwareUpdate(version: version) { [weak self] result in
            switch result {
            case let .success(firmwareVersionInfo):
                if firmwareVersionInfo.hasNewVersion {
                    BDLogger.info("New version：\(firmwareVersionInfo.version ?? "")")
                    BDLogger.info("Download link for the new version：\(firmwareVersionInfo.downloadUrl ?? "")")
                    BDLogger.info("New Version File Name：\(firmwareVersionInfo.fileName ?? "")")

                    guard let downloadUrl = firmwareVersionInfo.downloadUrl, !downloadUrl.isEmpty,
                          let fileName = firmwareVersionInfo.fileName, !fileName.isEmpty,
                          let newVersion = firmwareVersionInfo.version, !newVersion.isEmpty else {
                        BDLogger.error("Firmware information retrieval error. Please try again.")
                        return
                    }

                    self?.downloadAndUpgradeFirmware(downloadUrl: downloadUrl, fileName: fileName)
                } else {
                    BDLogger.info("This is the latest version.")
                }

            case let .failure(error):
                BDLogger.error("Failed to check for firmware updates: \(error)")
            }
        }
    }

    /// Download the firmware and perform the Apollo upgrade
    private func downloadAndUpgradeFirmware(downloadUrl: String, fileName: String) {
        guard let destinationPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            BDLogger.error("Unable to retrieve the document directory")
            return
        }

        BCLRingManager.shared.downloadFirmware(
            url: downloadUrl,
            fileName: fileName,
            destinationPath: destinationPath,
            progress: { progressValue in
                BDLogger.info("Download progress：\(Int(progressValue * 100))%")
            },
            completion: { [weak self] result in
                switch result {
                case let .success(filePath):
                    BDLogger.info("Firmware download successful：\(filePath)")
                    self?.performApolloUpgrade(filePath: filePath)

                case let .failure(error):
                    BDLogger.error("Firmware download failed：\(error)")
                }
            }
        )
    }

    /// Execute the Apollo firmware upgrade
    private func performApolloUpgrade(filePath: String) {
        BCLRingManager.shared.apolloUpgradeFirmware(
            filePath: filePath,
            progressHandler: { progress in
                BDLogger.info("Current progress：\(progress)%")
            },
            completion: { result in
                switch result {
                case .success:
                    BDLogger.info("Upgrade successful")
                case .failure:
                    BDLogger.error("Upgrade failed")
                }
            }
        )
    }
}
