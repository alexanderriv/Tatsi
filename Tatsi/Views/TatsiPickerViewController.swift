//
//  TatsiPickerViewController.swift
//  Tatsi
//
//  Created by Rens Verhoeven on 06/07/2017.
//  Copyright © 2017 Awkward BV. All rights reserved.
//

import UIKit
import Photos

final public class TatsiPickerViewController: UINavigationController {
  
  // MARK: - Public properties
  
  public let config: TatsiConfig
  
  public weak var pickerDelegate: TatsiPickerViewControllerDelegate?
  
  override public var preferredStatusBarStyle: UIStatusBarStyle {
    return config.preferredStatusBarStyle
  }
  
  // MARK: - Internal properties
  
  /// Persists the assets that a user has selected between albumns. 
  internal var selectedAssets: [PHAsset] = []
  
  // MARK: - Initializers
  
  public init(config: TatsiConfig = TatsiConfig.default) {
    self.config = config
    super.init(nibName: nil, bundle: nil)
    
    navigationBar.barTintColor = config.colors.background
    navigationBar.tintColor = config.colors.link
    
    setIntialViewController()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if #available(iOS 13.0, *) {
      setAppearanceForNavigationBar()
      view.layoutIfNeeded()
      view.updateConstraintsIfNeeded()
    }
  }
  
  // MARK: - Helpers
  
  internal func setIntialViewController() {
    switch PHPhotoLibrary.authorizationStatus() {
    case .authorized, .limited:
      //Authorized, show the album view or the album detail view.
      var album: PHAssetCollection?
      let userLibrary = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil).firstObject
      switch config.firstView {
      case .userLibrary:
        album = userLibrary
      case .album(let collection):
        album = collection
      default:
        break
      }
      if let initialAlbum = album ?? userLibrary, config.singleViewMode {
        viewControllers = [AssetsGridViewController(album: initialAlbum)]
      } else {
        showAlbumViewController(with: album)
      }
      
    case .denied, .notDetermined, .restricted:
      // Not authorized, show the view to give access
      viewControllers = [AuthorizationViewController()]
    @unknown default:
      assertionFailure("Unknown authorization status detected.")
    }
  }
  
  private func showAlbumViewController(with collection: PHAssetCollection?) {
    if let collection = collection {
      viewControllers = [AlbumsViewController(), AssetsGridViewController(album: collection)]
    } else {
      viewControllers = [AlbumsViewController()]
    }
  }
  
  @available(iOS 13, *)
  private func setAppearanceForNavigationBar() {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = config.navBarBackgroundColor
    if let font = config.navBarTitleFontType {
      appearance.titleTextAttributes = [
        .foregroundColor: config.navBarTitleTextColor,
        NSAttributedString.Key.font: font
      ]
    } else {
      appearance.titleTextAttributes = [
        .foregroundColor: config.navBarTitleTextColor
      ]
    }
    // The below line is needed for iOS 14 for some odd reason.
    navigationBar.barTintColor = config.navBarBackgroundColor
    navigationBar.standardAppearance = appearance
    navigationBar.scrollEdgeAppearance = appearance
  }
  
  
  
  internal func customCancelButtonItem() -> UIBarButtonItem? {
    return pickerDelegate?.cancelBarButtonItem(for: self)
  }
  
  internal func customDoneButtonItem() -> UIButton? {
    return pickerDelegate?.doneBarButtonItem(for: self)
  }
  
}
