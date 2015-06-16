/*****************************************************************************
 * VLCSettingsController.m
 * VLC for iOS
 *****************************************************************************
 * Copyright (c) 2013 VideoLAN. All rights reserved.
 * $Id$
 *
 * Authors: Felix Paul Kühne <fkuehne # videolan.org>
 *          Gleb Pinigin <gpinigin # gmail.com>
 *          Carola Nitz <nitz.carola # googlemail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

#import "VLCSettingsController.h"
#import "VLCPlaylistViewController.h"
#import "IASKSettingsReader.h"
#import "IASKAppSettingsViewController.h"
#import "PAPasscodeViewController.h"
#import "VLCKeychainCoordinator.h"

@interface VLCSettingsController ()<PAPasscodeViewControllerDelegate, IASKSettingsDelegate>

@end

@implementation VLCSettingsController

- (id)init
{
    self = [super init];
    if (self)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingDidChange:) name:kIASKAppSettingChanged object:nil];

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)settingDidChange:(NSNotification*)notification
{
    if ([notification.object isEqual:kVLCSettingPasscodeOnKey]) {
        BOOL passcodeOn = [[notification.userInfo objectForKey:kVLCSettingPasscodeOnKey] boolValue];

        if (passcodeOn) {
            PAPasscodeViewController *passcodeLockController = [[PAPasscodeViewController alloc] initForAction:PasscodeActionSet];
            passcodeLockController.delegate = self;
            [self.viewController presentViewController:passcodeLockController animated:YES completion:nil];
        } else {
            [[VLCKeychainCoordinator defaultCoordinator] setPasscode:nil];
        }
    }
    if ([notification.object isEqual:kVLCSettingPlaybackGestures]) {
        BOOL enabled = (BOOL)[[notification.userInfo objectForKey:@"EnableGesturesToControlPlayback"] intValue];
        [self.viewController setHiddenKeys:enabled ? nil : [NSSet setWithObjects:@"EnableVariableJumpDuration", nil] animated:YES];
    }
}

- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender
{
    [[VLCSidebarController sharedInstance] toggleSidebar];
}

#pragma mark - PAPasscode delegate

- (void)PAPasscodeViewControllerDidCancel:(PAPasscodeViewController *)controller
{
    [[VLCKeychainCoordinator defaultCoordinator] setPasscode:nil];

    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)PAPasscodeViewControllerDidSetPasscode:(PAPasscodeViewController *)controller
{
    [[VLCKeychainCoordinator defaultCoordinator] setPasscode:controller.passcode];

    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
