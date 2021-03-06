//
//  ARAnalytics.m
//  Art.sy
//
//  Created by orta therox on 18/12/2012.
//  Copyright (c) 2012 Art.sy. All rights reserved.
//

#import "ARAnalytics.h"
#import "ARAnalyticalProvider.h"
#import "ARAnalyticsProviders.h"

static ARAnalytics *_sharedAnalytics;

@interface ARAnalytics ()
@property (strong) NSMutableDictionary *eventsDictionary;
@property (strong) NSSet *providers;
@end

#if !TARGET_OS_IPHONE
@implementation UIViewController @end
@implementation UINavigationController @end
#endif

@implementation ARAnalytics

+ (void) initialize {
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        _sharedAnalytics = [[ARAnalytics alloc] init];
        _sharedAnalytics.providers = [NSSet set];
    });
}

#pragma mark -
#pragma mark Analytics Setup

// By using the constants at the bottom you can 

+ (void)setupWithAnalytics:(NSDictionary *)analyticsDictionary {
    if (analyticsDictionary[ARTestFlightAppToken]) {
        [self setupTestFlightWithAppToken:analyticsDictionary[ARTestFlightAppToken]];
    }

    if (analyticsDictionary[ARFlurryAPIKey]) {
        [self setupFlurryWithAPIKey:analyticsDictionary[ARFlurryAPIKey]];
    }

    if (analyticsDictionary[ARGoogleAnalyticsID]) {
        [self setupGoogleAnalyticsWithID:analyticsDictionary[ARGoogleAnalyticsID]];
    }

    if (analyticsDictionary[ARKISSMetricsAPIKey]) {
        [self setupKISSMetricsWithAPIKey:analyticsDictionary[ARKISSMetricsAPIKey]];
    }

    if (analyticsDictionary[ARLocalyticsAppKey]) {
        [self setupLocalyticsWithAppKey:analyticsDictionary[ARLocalyticsAppKey]];
    }

    if (analyticsDictionary[ARMixpanelToken]) {
        // ARMixpanelHost is nil if you want the default provider. So we can make
        // the presumption of it here.
        [self setupMixpanelWithToken:analyticsDictionary[ARMixpanelToken] andHost:analyticsDictionary[ARMixpanelHost]];
    }

    if (analyticsDictionary[ARCountlyAppKey] && analyticsDictionary[ARCountlyHost]) {
        [self setupCountlyWithAppKey:analyticsDictionary[ARCountlyAppKey] andHost:analyticsDictionary[ARCountlyHost]];
    }

    if (analyticsDictionary[ARBugsnagAPIKey]) {
        [self setupBugsnagWithAPIKey:analyticsDictionary[ARBugsnagAPIKey]];
    }
    
    if (analyticsDictionary[ARHelpshiftAppID] && analyticsDictionary[ARHelpshiftDomainName] && analyticsDictionary[ARHelpshiftAPIKey]) {
        [self setupHelpshiftWithAppID:analyticsDictionary[ARHelpshiftAppID] domainName:analyticsDictionary[ARHelpshiftDomainName] apiKey:analyticsDictionary[ARHelpshiftAPIKey]];
    }
    
    if (analyticsDictionary[ARTapstreamAccountName] && analyticsDictionary[ARTapstreamDeveloperSecret]) {
        [self setupTapstreamWithAccountName:analyticsDictionary[ARTapstreamAccountName] developerSecret:analyticsDictionary[ARTapstreamDeveloperSecret] config:analyticsDictionary[ARTapstreamConfig]];
    }
    
    if (analyticsDictionary[ARNewRelicAppToken]) {
        [self setupNewRelicWithAppToken:analyticsDictionary[ARNewRelicAppToken]];
    }
    
    if (analyticsDictionary[ARAmplitudeAPIKey]) {
        [self setupAmplitudeWithAPIKey:analyticsDictionary[ARAmplitudeAPIKey]];
    }

    if (analyticsDictionary[ARHockeyAppBetaID]) {
        [self setupHockeyAppWithBetaID:analyticsDictionary[ARHockeyAppBetaID] liveID:analyticsDictionary[ARHockeyAppLiveID]];
    }
    
    if (analyticsDictionary[ARParseApplicationID] && analyticsDictionary[ARParseClientKey]) {
        [self setupParseAnalyticsWithApplicationID:analyticsDictionary[ARParseApplicationID] clientKey:analyticsDictionary[ARParseClientKey]];
    }

    if (analyticsDictionary[ARHeapAppID]) {
        [self setupHeapAnalyticsWithApplicationID:analyticsDictionary[ARHeapAppID]];
    }
    
    if (analyticsDictionary[ARChartbeatID]) {
        [self setupChartbeatWithApplicationID:analyticsDictionary[ARChartbeatID]];
    }

    // Crashlytics / Crittercism should stay at the bottom of this,
    // as they both need to register exceptions, and you'd only use one.

    if (analyticsDictionary[ARCrashlyticsAPIKey]) {
        [self setupCrashlyticsWithAPIKey:analyticsDictionary[ARCrashlyticsAPIKey]];
    }

    if (analyticsDictionary[ARCrittercismAppID]) {
        [self setupCrittercismWithAppID:analyticsDictionary[ARCrittercismAppID]];
    }
}

+ (void)setupTestFlightWithAppToken:(NSString *)token {
#ifdef AR_TESTFLIGHT_EXISTS
    TestFlightProvider *provider = [[TestFlightProvider alloc] initWithIdentifier:token];
    _sharedAnalytics.providers = [_sharedAnalytics.providers setByAddingObject:provider];
#endif
}

+ (void)setupCrashlyticsWithAPIKey:(NSString *)key {
#ifdef AR_CRASHLYTICS_EXISTS
    CrashlyticsProvider *provider = [[CrashlyticsProvider alloc] initWithIdentifier:key];
    _sharedAnalytics.providers = [_sharedAnalytics.providers setByAddingObject:provider];
#endif
}

+ (void)setupMixpanelWithToken:(NSString *)token {
    [self setupMixpanelWithToken:token andHost:nil];
}

+ (void)setupMixpanelWithToken:(NSString *)token andHost:(NSString *)host {
#ifdef AR_MIXPANEL_EXISTS
    MixpanelProvider *provider = [[MixpanelProvider alloc] initWithIdentifier:token andHost:host];
    _sharedAnalytics.providers = [_sharedAnalytics.providers setByAddingObject:provider];
#endif
}

+ (void)setupFlurryWithAPIKey:(NSString *)key {
#ifdef AR_FLURRY_EXISTS
    FlurryProvider *provider = [[FlurryProvider alloc] initWithIdentifier:key];
    _sharedAnalytics.providers = [_sharedAnalytics.providers setByAddingObject:provider];
#endif
}

+ (void)setupGoogleAnalyticsWithID:(NSString *)identifier {
#ifdef AR_GOOGLEANALYTICS_EXISTS
    GoogleAnalyticsProvider *provider = [[GoogleAnalyticsProvider alloc] initWithIdentifier:identifier];
    _sharedAnalytics.providers = [_sharedAnalytics.providers setByAddingObject:provider];
#endif
}

+ (void)setupLocalyticsWithAppKey:(NSString *)key {
#ifdef AR_LOCALYTICS_EXISTS
    LocalyticsProvider *provider = [[LocalyticsProvider alloc] initWithIdentifier:key];
    _sharedAnalytics.providers = [_sharedAnalytics.providers setByAddingObject:provider];
#endif
}

+ (void)setupKISSMetricsWithAPIKey:(NSString *)key {
#ifdef AR_KISSMETRICS_EXISTS
    KISSMetricsProvider *provider = [[KISSMetricsProvider alloc] initWithIdentifier:key];
    _sharedAnalytics.providers = [_sharedAnalytics.providers setByAddingObject:provider];
#endif
}

+ (void)setupCrittercismWithAppID:(NSString *)appID {
#ifdef AR_CRITTERCISM_EXISTS
    CrittercismProvider *provider = [[CrittercismProvider alloc] initWithIdentifier:appID];
    _sharedAnalytics.providers = [_sharedAnalytics.providers setByAddingObject:provider];
#endif
}

+ (void)setupCountlyWithAppKey:(NSString *)key andHost:(NSString *)host {
#ifdef AR_COUNTLY_EXISTS
    CountlyProvider *provider = [[CountlyProvider alloc] initWithAppKey:key andHost:host];
    _sharedAnalytics.providers = [_sharedAnalytics.providers setByAddingObject:provider];
#endif
}

+ (void)setupBugsnagWithAPIKey:(NSString *)key {
#ifdef AR_BUGSNAG_EXISTS
    BugsnagProvider *provider = [[BugsnagProvider alloc] initWithIdentifier:key];
    _sharedAnalytics.providers = [_sharedAnalytics.providers setByAddingObject:provider];
#endif
}

+ (void)setupHelpshiftWithAppID:(NSString *)appID domainName:(NSString *)domainName apiKey:(NSString *)apiKey {
#ifdef AR_HELPSHIFT_EXISTS
    HelpshiftProvider *provider = [[HelpshiftProvider alloc] initWithAppID:appID domainName:domainName apiKey:apiKey];
    _sharedAnalytics.providers = [_sharedAnalytics.providers setByAddingObject:provider];    
#endif
}

+ (void)setupTapstreamWithAccountName:(NSString *)accountName developerSecret:(NSString *)developerSecret {
#ifdef AR_TAPSTREAM_EXISTS
    TapstreamProvider *provider = [[TapstreamProvider alloc] initWithAccountName:accountName developerSecret:developerSecret];
    _sharedAnalytics.providers = [_sharedAnalytics.providers setByAddingObject:provider];
#endif
}

+ (void)setupTapstreamWithAccountName:(NSString *)accountName developerSecret:(NSString *)developerSecret config:(TSConfig *)config {
#ifdef AR_TAPSTREAM_EXISTS
    TapstreamProvider *provider = [[TapstreamProvider alloc] initWithAccountName:accountName developerSecret:developerSecret config:config];
    _sharedAnalytics.providers = [_sharedAnalytics.providers setByAddingObject:provider];
#endif
}

+ (void)setupNewRelicWithAppToken:(NSString *)token {
#ifdef AR_NEWRELIC_EXISTS
    NewRelicProvider *provider = [[NewRelicProvider alloc] initWithIdentifier:token];
    _sharedAnalytics.providers = [_sharedAnalytics.providers setByAddingObject:provider];
#endif
}

+ (void)setupAmplitudeWithAPIKey:(NSString *)key {
#ifdef AR_AMPLITUDE_EXISTS
     AmplitudeProvider *provider = [[AmplitudeProvider alloc] initWithIdentifier:key];
    _sharedAnalytics.providers = [_sharedAnalytics.providers setByAddingObject:provider];
#endif
}

+ (void)setupHockeyAppWithBetaID:(NSString *)betaID {
#ifdef AR_HOCKEYAPP_EXISTS
    [self setupHockeyAppWithBetaID:betaID liveID:nil];
#endif
}

+ (void)setupHockeyAppWithBetaID:(NSString *)betaID liveID:(NSString *)liveID {
#ifdef AR_HOCKEYAPP_EXISTS
    HockeyAppProvider *provider = [[HockeyAppProvider alloc] initWithBetaIdentifier:betaID liveIdentifier:liveID];
    _sharedAnalytics.providers = [_sharedAnalytics.providers setByAddingObject:provider];
#endif
}

+(void)setupParseAnalyticsWithApplicationID:(NSString *)appID clientKey:(NSString *)clientKey {
#ifdef AR_PARSEANALYTICS_EXISTS
    ParseAnalyticsProvider *provider = [[ParseAnalyticsProvider alloc] initWithApplicationID:appID clientKey:clientKey];
    _sharedAnalytics.providers = [_sharedAnalytics.providers setByAddingObject:provider];

#endif
}

+ (void)setupHeapAnalyticsWithApplicationID:(NSString *)appID {
#ifdef AR_HEAPANALYTICS_EXISTS
    HeapAnalyticsProvider *provider = [[HeapAnalyticsProvider alloc] initWithIdentifier:appID];
    _sharedAnalytics.providers = [_sharedAnalytics.providers setByAddingObject:provider];
#endif
}

+ (void)setupChartbeatWithApplicationID:(NSString *)appID {
#ifdef AR_CHARTBEAT_EXISTS
    ChartbeatProvider *provider = [[ChartbeatProvider alloc] initWithIdentifier:appID];
    _sharedAnalytics.providers = [_sharedAnalytics.providers setByAddingObject:provider];
#endif
}



#pragma mark -
#pragma mark User Setup

// deprecated;
+ (void)identifyUserwithID:(NSString *)userID andEmailAddress:(NSString *)email {
    [self identifyUserWithID:userID andEmailAddress:email];
}


+ (void)identifyUserWithID:(NSString *)userID andEmailAddress:(NSString *)email {
    [_sharedAnalytics iterateThroughProviders:^(ARAnalyticalProvider *provider) {
        [provider identifyUserWithID:userID andEmailAddress:email];
    }];
}

+ (void)setUserProperty:(NSString *)property toValue:(NSString *)value {
    if (value == nil) {
        NSLog(@"ARAnalytics: Value cannot be nil ( %@ ) ", property);
        return;
    }

    [_sharedAnalytics iterateThroughProviders:^(ARAnalyticalProvider *provider) {
        [provider setUserProperty:property toValue:value];
    }];
}

+ (void)incrementUserProperty:(NSString *)counterName byInt:(int)amount {
    [_sharedAnalytics iterateThroughProviders:^(ARAnalyticalProvider *provider) {
        [provider incrementUserProperty:counterName byInt:@(amount)];
    }];
}

#pragma mark -
#pragma mark Events


+ (void)event:(NSString *)event {
    [self event:event withProperties:nil];
}

+ (void)event:(NSString *)event withProperties:(NSDictionary *)properties {
    [_sharedAnalytics iterateThroughProviders:^(ARAnalyticalProvider *provider) {
        [provider event:event withProperties:properties];
    }];
}

#pragma mark -
#pragma mark Errors

+ (void)error:(NSError *)error {
	[self error:error withMessage:nil];
}

+ (void)error:(NSError *)error withMessage:(NSString *)message {
	[_sharedAnalytics iterateThroughProviders:^(ARAnalyticalProvider *provider) {
		[provider error:error withMessage:message];
	}];
}

#pragma mark -
#pragma mark Monitor Navigation Controller

+ (void)pageView:(NSString *)pageTitle {
    if (!pageTitle) return;
    
    [_sharedAnalytics iterateThroughProviders:^(ARAnalyticalProvider *provider) {
        [provider didShowNewPageView:pageTitle];
    }];
}

+ (void)monitorNavigationViewController:(UINavigationController *)controller {
#if TARGET_OS_IPHONE
    controller.delegate = _sharedAnalytics;
#endif
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
#if TARGET_OS_IPHONE
    [self.class pageView:viewController.title];
#endif
}

#pragma mark -
#pragma mark Timing Events

+ (void)startTimingEvent:(NSString *)event {
    if (!_sharedAnalytics.eventsDictionary) {
        _sharedAnalytics.eventsDictionary = [NSMutableDictionary dictionary];
    }
    _sharedAnalytics.eventsDictionary[event] = [NSDate date];
}

+ (void)finishTimingEvent:(NSString *)event {
    NSDate *startDate = _sharedAnalytics.eventsDictionary[event];
    if (!startDate) {
        NSLog(@"ARAnalytics: finish timing event called without a corrosponding start timing event");
        return;
    }

    NSTimeInterval eventInterval = [[NSDate date] timeIntervalSinceDate:startDate];
    [_sharedAnalytics.eventsDictionary removeObjectForKey:event];

    [_sharedAnalytics iterateThroughProviders:^(ARAnalyticalProvider *provider) {
        [provider logTimingEvent:event withInterval:@(eventInterval)];
    }];
}


#pragma mark -
#pragma mark Util

- (void)iterateThroughProviders:(void(^)(ARAnalyticalProvider *provider))providerBlock {
    for (ARAnalyticalProvider *provider in _providers) {
        providerBlock(provider);
    }
}

@end

void ARLog (NSString *format, ...) {
    if (format == nil) {
        printf("nil \n");
        return;
    }
    // Get a reference to the arguments that follow the format parameter
    va_list argList;
    va_start(argList, format);
    // Perform format string argument substitution, reinstate %% escapes, then print

    @autoreleasepool {
      NSString *parsedFormatString = [[NSString alloc] initWithFormat:format arguments:argList];
      parsedFormatString = [parsedFormatString stringByReplacingOccurrencesOfString:@"%%" withString:@"%%%%"];
      printf("ARLog : %s\n", parsedFormatString.UTF8String);

      [_sharedAnalytics iterateThroughProviders:^(ARAnalyticalProvider *provider) {
          [provider remoteLog:parsedFormatString];
      }];
    }

    va_end(argList);
}

void ARAnalyticsEvent (NSString *event, NSDictionary *properties) {
  @try {
    [ARAnalytics event:event withProperties:properties]
  }

  @catch (NSException *exception) {
    NSLog(@"ARAnalytics: Exception raised when handling event %@ - %@ - %@", event, exception.name, exception.reason);
  }
}

const NSString *ARCountlyAppKey = @"ARCountlyAppKey";
const NSString *ARCountlyHost = @"ARCountlyHost";
const NSString *ARTestFlightAppToken = @"ARTestFlight";
const NSString *ARCrashlyticsAPIKey = @"ARCrashlytics";
const NSString *ARMixpanelToken = @"ARMixpanel";
const NSString *ARMixpanelHost = @"ARMixpanelHost";
const NSString *ARFlurryAPIKey = @"ARFlurry";
const NSString *ARBugsnagAPIKey = @"ARBugsnag";
const NSString *ARLocalyticsAppKey = @"ARLocalytics";
const NSString *ARKISSMetricsAPIKey = @"ARKISSMetrics";
const NSString *ARCrittercismAppID = @"ARCrittercism";
const NSString *ARGoogleAnalyticsID = @"ARGoogleAnalytics";
const NSString *ARHelpshiftAppID = @"ARHelpshiftAppID";
const NSString *ARHelpshiftDomainName = @"ARHelpshiftDomainName";
const NSString *ARHelpshiftAPIKey = @"ARHelpshiftAPIKey";
const NSString *ARTapstreamAccountName = @"ARTapstreamAccountName";
const NSString *ARTapstreamDeveloperSecret = @"ARTapstreamDeveloperSecret";
const NSString *ARTapstreamConfig = @"ARTapstreamConfig";
const NSString *ARNewRelicAppToken = @"ARNewRelicAppToken";
const NSString *ARAmplitudeAPIKey = @"ARAmplitudeAPIKey";
const NSString *ARHockeyAppLiveID = @"ARHockeyAppLiveID";
const NSString *ARHockeyAppBetaID = @"ARHockeyAppBetaID";
const NSString *ARParseApplicationID = @"ARParseApplicationID";
const NSString *ARParseClientKey = @"ARParseClientKey";
const NSString *ARHeapAppID = @"ARHeapAppID";
const NSString *ARChartbeatID = @"ARChartbeatID";
