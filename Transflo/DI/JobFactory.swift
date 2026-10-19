import TransfloData
import TransfloDomain
import TransfloSystem

/// Builds the job center: the runner that routes each wedge, the result disc, notifications and
/// Finder reveal, plus the hint card for messages that aren't jobs.
struct JobFactory {
    let notifier: UserNotificationPoster
    /// The disc that shows each job where its wheel was.
    let results: JobResultDiscPresenter
    /// Short messages that aren't jobs.
    let hints: HintHUDPresenter
    let center: JobCenter

    init(
        localizer: Localizer,
        conversion: any WheelJobRunning,
        tools: any WheelJobRunning,
        actions: any WheelJobRunning,
        preferences: (any ToolPreferencesRepository)? = nil,
        resultVisibleFor: Duration = .seconds(2.5)
    ) {
        let revealer = WorkspaceFileRevealer()
        let notifier = UserNotificationPoster(revealer: revealer)
        let results = JobResultDiscPresenter(localizer: localizer, successDelay: resultVisibleFor)
        let runner = WheelJobRouter(conversion: conversion, tools: tools, actions: actions)
        center = JobCenter(
            runOption: RunWheelOptionUseCase(runner: runner),
            hud: results,
            notifier: notifier,
            revealer: revealer,
            localizer: localizer,
            preparation: preferences.map {
                PrepareWheelJobUseCase(preferences: $0, summaries: FileDragSummaryProvider())
            }
        )
        results.attach(to: center)
        self.notifier = notifier
        self.results = results
        hints = HintHUDPresenter(localizer: localizer)
    }
}
