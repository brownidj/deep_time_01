part of 'timeline_screen.dart';

mixin _TimelineScreenPreferences on State<TimelineScreen> {
  TimeLabelMode get _labelMode;
  set _labelMode(TimeLabelMode value);
  CladeViewMode get _cladeViewMode;
  set _cladeViewMode(CladeViewMode value);
  String get _cladeCategoryId;
  set _cladeCategoryId(String value);
  Set<TimelineTrack> get _visibleTracks;
  set _visibleTracks(Set<TimelineTrack> value);
  List<CladeDisplayGroup> get _cladeDisplayGroups;
  bool get _labelModeRetryScheduled;
  set _labelModeRetryScheduled(bool value);
  int get _labelModeRetryCount;
  set _labelModeRetryCount(int value);
  Future<void> _loadPreferences() async {
    if (!widget.enablePreferences) {
      return;
    }
    if (_labelModeRetryCount >= _maxLabelModeRetries) {
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_labelModeKey);
      final storedScale = prefs.getDouble(_timelineScaleKey);
      final storedCladeView = prefs.getString(_cladeViewModeKey);
      final storedCladeCategory = prefs.getString(_cladeCategoryKey);
      final storedContinentVisible = prefs.getBool(_continentColumnVisibleKey);
      final storedPaleoEcologyVisible = prefs.getBool(
        _paleoEcologyColumnVisibleKey,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _labelMode = parseTimeLabelMode(stored);
        _cladeViewMode = parseCladeViewMode(storedCladeView);
        if (storedCladeCategory != null && storedCladeCategory.isNotEmpty) {
          _cladeCategoryId = storedCladeCategory;
        }
        if (storedScale != null) {
          AppDebug.timelineScale = storedScale;
        }
        if (storedContinentVisible != null) {
          final nextVisible = Set<TimelineTrack>.from(_visibleTracks);
          if (!storedContinentVisible) {
            nextVisible.remove(TimelineTrack.continents);
          }
          _visibleTracks = nextVisible;
        }
        if (storedPaleoEcologyVisible != null) {
          final nextVisible = Set<TimelineTrack>.from(_visibleTracks);
          if (!storedPaleoEcologyVisible) {
            nextVisible.remove(TimelineTrack.paleoEcology);
          }
          _visibleTracks = nextVisible;
        }
      });
    } on PlatformException catch (error, stackTrace) {
      _scheduleLabelModeRetry(error);
      AppDebug.log(
        'Failed to load preferences',
        error: error,
        stackTrace: stackTrace,
      );
    } catch (error, stackTrace) {
      AppDebug.log(
        'Failed to load preferences',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _saveLabelMode(TimeLabelMode mode) async {
    if (!widget.enablePreferences) {
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_labelModeKey, mode.id);
    } on PlatformException catch (error, stackTrace) {
      _scheduleLabelModeRetry(error);
      AppDebug.log(
        'Failed to save label mode',
        error: error,
        stackTrace: stackTrace,
      );
    } catch (error, stackTrace) {
      AppDebug.log(
        'Failed to save label mode',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _saveTimelineScale(double scale) async {
    if (!widget.enablePreferences) {
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_timelineScaleKey, scale);
    } on PlatformException catch (error, stackTrace) {
      _scheduleLabelModeRetry(error);
      AppDebug.log(
        'Failed to save timeline scale',
        error: error,
        stackTrace: stackTrace,
      );
    } catch (error, stackTrace) {
      AppDebug.log(
        'Failed to save timeline scale',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _saveCladeViewMode(CladeViewMode mode) async {
    if (!widget.enablePreferences) {
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cladeViewModeKey, mode.id);
    } on PlatformException catch (error, stackTrace) {
      _scheduleLabelModeRetry(error);
      AppDebug.log(
        'Failed to save clade view mode',
        error: error,
        stackTrace: stackTrace,
      );
    } catch (error, stackTrace) {
      AppDebug.log(
        'Failed to save clade view mode',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _saveCladeCategory(String id) async {
    if (!widget.enablePreferences) {
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cladeCategoryKey, id);
    } on PlatformException catch (error, stackTrace) {
      _scheduleLabelModeRetry(error);
      AppDebug.log(
        'Failed to save clade category',
        error: error,
        stackTrace: stackTrace,
      );
    } catch (error, stackTrace) {
      AppDebug.log(
        'Failed to save clade category',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _saveContinentColumnVisible(bool visible) async {
    if (!widget.enablePreferences) {
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_continentColumnVisibleKey, visible);
    } on PlatformException catch (error, stackTrace) {
      _scheduleLabelModeRetry(error);
      AppDebug.log(
        'Failed to save continent column visibility',
        error: error,
        stackTrace: stackTrace,
      );
    } catch (error, stackTrace) {
      AppDebug.log(
        'Failed to save continent column visibility',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _savePaleoEcologyColumnVisible(bool visible) async {
    if (!widget.enablePreferences) {
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_paleoEcologyColumnVisibleKey, visible);
    } on PlatformException catch (error, stackTrace) {
      _scheduleLabelModeRetry(error);
      AppDebug.log(
        'Failed to save paleo-ecology column visibility',
        error: error,
        stackTrace: stackTrace,
      );
    } catch (error, stackTrace) {
      AppDebug.log(
        'Failed to save paleo-ecology column visibility',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _scheduleLabelModeRetry(PlatformException error) {
    if (_labelModeRetryScheduled || !widget.enablePreferences) {
      return;
    }
    if (error.code != 'channel-error') {
      return;
    }
    if (_labelModeRetryCount >= _maxLabelModeRetries) {
      return;
    }
    _labelModeRetryCount += 1;
    _labelModeRetryScheduled = true;
    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted || !widget.enablePreferences) {
        return;
      }
      _labelModeRetryScheduled = false;
      _loadPreferences();
    });
  }

  Future<void> _showLabelSettings(BuildContext context) async {
    final selected = await showDialog<TimeLabelMode>(
      context: context,
      builder: (context) {
        return TimelineSettingsDialog(
          labelMode: _labelMode,
          onScaleChanged: (value) {
            setState(() {
              AppDebug.timelineScale = value;
            });
            _saveTimelineScale(value);
          },
          cladeViewMode: _cladeViewMode,
          cladeCategoryId: _cladeCategoryId,
          cladeDisplayGroups: _cladeDisplayGroups,
          onCladeViewModeChanged: (mode) {
            setState(() {
              _cladeViewMode = mode;
            });
            _saveCladeViewMode(mode);
          },
          onCladeCategoryChanged: (id) {
            setState(() {
              _cladeCategoryId = id;
            });
            _saveCladeCategory(id);
          },
          visibleTracks: _visibleTracks,
          onTrackVisibilityChanged: (track, visible) {
            setState(() {
              final next = Set<TimelineTrack>.from(_visibleTracks);
              if (visible) {
                next.add(track);
              } else {
                next.remove(track);
              }
              _visibleTracks = next;
            });
            if (track == TimelineTrack.continents) {
              _saveContinentColumnVisible(visible);
            }
            if (track == TimelineTrack.paleoEcology) {
              _savePaleoEcologyColumnVisible(visible);
            }
          },
        );
      },
    );

    if (selected == null || selected == _labelMode) {
      return;
    }

    setState(() {
      _labelMode = selected;
    });
    await _saveLabelMode(selected);
  }
}

mixin _TimelineScreenCladeData on State<TimelineScreen> {
  set _cladeDisplayGroups(List<CladeDisplayGroup> value);
  set _cladeRepresentativeIds(List<String> value);
  Future<void> _loadCladeDisplayGroups() async {
    try {
      final groups = await widget.dependencies.cladeDisplayGroupRepository
          .fetchDisplayGroups();
      if (!mounted) {
        return;
      }
      setState(() {
        _cladeDisplayGroups = groups;
      });
    } catch (error, stackTrace) {
      AppDebug.log(
        'Failed to load clade display groups',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _loadCladeRepresentativeIds() async {
    try {
      final ids = await widget.dependencies.cladeRepresentativeRepository
          .fetchRepresentativeIds();
      if (!mounted) {
        return;
      }
      setState(() {
        _cladeRepresentativeIds = ids;
      });
    } catch (error, stackTrace) {
      AppDebug.log(
        'Failed to load clade representative ids',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
