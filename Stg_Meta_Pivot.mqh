/**
 * @file
 * Implements Pivot meta strategy.
 */

// Prevents processing this includes file multiple times.
#ifndef STG_META_PIVOT_MQH
#define STG_META_PIVOT_MQH

// User input params.
INPUT2_GROUP("Meta Pivot strategy: main params");
INPUT2 ENUM_STRATEGY Meta_Pivot_Strategy_Pivot1 = STRAT_BANDS;  // Strategy for Pivot in range S1-R1
INPUT2 ENUM_STRATEGY Meta_Pivot_Strategy_Pivot2 = STRAT_FORCE;  // Strategy for Pivot in range S2-R2
INPUT2 ENUM_STRATEGY Meta_Pivot_Strategy_Pivot3 = STRAT_NONE;   // Strategy for Pivot in range S3-R3
INPUT2 ENUM_STRATEGY Meta_Pivot_Strategy_Pivot4 = STRAT_NONE;   // Strategy for Pivot in and beyond range S4-R4
INPUT2_GROUP("Meta Pivot strategy: common params");
INPUT2 float Meta_Pivot_LotSize = 0;                // Lot size
INPUT2 int Meta_Pivot_SignalOpenMethod = 0;         // Signal open method
INPUT2 float Meta_Pivot_SignalOpenLevel = 0;        // Signal open level
INPUT2 int Meta_Pivot_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT2 int Meta_Pivot_SignalOpenFilterTime = 3;     // Signal open filter time (0-31)
INPUT2 int Meta_Pivot_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT2 int Meta_Pivot_SignalCloseMethod = 0;        // Signal close method
INPUT2 int Meta_Pivot_SignalCloseFilter = 32;       // Signal close filter (-127-127)
INPUT2 float Meta_Pivot_SignalCloseLevel = 0;       // Signal close level
INPUT2 int Meta_Pivot_PriceStopMethod = 0;          // Price limit method
INPUT2 float Meta_Pivot_PriceStopLevel = 2;         // Price limit level
INPUT2 int Meta_Pivot_TickFilterMethod = 32;        // Tick filter method (0-255)
INPUT2 float Meta_Pivot_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT2 short Meta_Pivot_Shift = 0;                  // Shift
INPUT2 float Meta_Pivot_OrderCloseLoss = 200;       // Order close loss
INPUT2 float Meta_Pivot_OrderCloseProfit = 200;     // Order close profit
INPUT2 int Meta_Pivot_OrderCloseTime = 2880;        // Order close time in mins (>0) or bars (<0)
INPUT3_GROUP("Meta Pivot strategy: Pivot indicator params");
INPUT3 ENUM_PP_TYPE Meta_Pivot_Indi_Pivot_Type = PP_CAMARILLA;                   // Calculation method
INPUT3 int Meta_Pivot_Indi_Pivot_Shift = 1;                                      // Shift
INPUT3 ENUM_IDATA_SOURCE_TYPE Meta_Pivot_Indi_Pivot_SourceType = IDATA_BUILTIN;  // Source type

// Enums.
enum META_PIVOT_INDI_PIVOT_MODE {
  META_PIVOT_INDI_PIVOT_PP = 0,
  META_PIVOT_INDI_PIVOT_R1,
  META_PIVOT_INDI_PIVOT_R2,
  META_PIVOT_INDI_PIVOT_R3,
  META_PIVOT_INDI_PIVOT_R4,
  META_PIVOT_INDI_PIVOT_S1,
  META_PIVOT_INDI_PIVOT_S2,
  META_PIVOT_INDI_PIVOT_S3,
  META_PIVOT_INDI_PIVOT_S4,
};

// Structs.
// Defines struct with default user strategy values.
struct Stg_Meta_Pivot_Params_Defaults : StgParams {
  Stg_Meta_Pivot_Params_Defaults()
      : StgParams(::Meta_Pivot_SignalOpenMethod, ::Meta_Pivot_SignalOpenFilterMethod, ::Meta_Pivot_SignalOpenLevel,
                  ::Meta_Pivot_SignalOpenBoostMethod, ::Meta_Pivot_SignalCloseMethod, ::Meta_Pivot_SignalCloseFilter,
                  ::Meta_Pivot_SignalCloseLevel, ::Meta_Pivot_PriceStopMethod, ::Meta_Pivot_PriceStopLevel,
                  ::Meta_Pivot_TickFilterMethod, ::Meta_Pivot_MaxSpread, ::Meta_Pivot_Shift) {
    Set(STRAT_PARAM_LS, ::Meta_Pivot_LotSize);
    Set(STRAT_PARAM_OCL, ::Meta_Pivot_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, ::Meta_Pivot_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, ::Meta_Pivot_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, ::Meta_Pivot_SignalOpenFilterTime);
  }
};

class Stg_Meta_Pivot : public Strategy {
 protected:
  DictStruct<long, Ref<Strategy>> strats;

 public:
  Stg_Meta_Pivot(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_Meta_Pivot *Init(ENUM_TIMEFRAMES _tf = NULL, EA *_ea = NULL) {
    // Initialize strategy initial values.
    Stg_Meta_Pivot_Params_Defaults stg_meta_pivot_defaults;
    StgParams _stg_params(stg_meta_pivot_defaults);
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_Meta_Pivot(_stg_params, _tparams, _cparams, "(Meta) Pivot");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {
    StrategyAdd(Meta_Pivot_Strategy_Pivot1, 0);
    StrategyAdd(Meta_Pivot_Strategy_Pivot2, 1);
    StrategyAdd(Meta_Pivot_Strategy_Pivot3, 2);
    StrategyAdd(Meta_Pivot_Strategy_Pivot4, 3);
    // Initialize indicators.
    IndiPivotParams _indi_params(::Meta_Pivot_Indi_Pivot_Type, ::Meta_Pivot_Indi_Pivot_Shift);
    _indi_params.SetTf(PERIOD_D1);
    SetIndicator(new Indi_Pivot(_indi_params));
  }

  /**
   * Sets strategy.
   */
  bool StrategyAdd(ENUM_STRATEGY _sid, long _index) {
    bool _result = true;
    long _magic_no = Get<long>(STRAT_PARAM_ID);
    ENUM_TIMEFRAMES _tf = Get<ENUM_TIMEFRAMES>(STRAT_PARAM_TF);

    switch (_sid) {
      case STRAT_NONE:
        break;
      case STRAT_AC:
        _result &= StrategyAdd<Stg_AC>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_AD:
        _result &= StrategyAdd<Stg_AD>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_ADX:
        _result &= StrategyAdd<Stg_ADX>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_AMA:
        _result &= StrategyAdd<Stg_AMA>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_ARROWS:
        _result &= StrategyAdd<Stg_Arrows>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_ASI:
        _result &= StrategyAdd<Stg_ASI>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_ATR:
        _result &= StrategyAdd<Stg_ATR>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_ALLIGATOR:
        _result &= StrategyAdd<Stg_Alligator>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_AWESOME:
        _result &= StrategyAdd<Stg_Awesome>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_BWMFI:
        _result &= StrategyAdd<Stg_BWMFI>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_BANDS:
        _result &= StrategyAdd<Stg_Bands>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_BEARS_POWER:
        _result &= StrategyAdd<Stg_BearsPower>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_BULLS_POWER:
        _result &= StrategyAdd<Stg_BullsPower>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_CCI:
        _result &= StrategyAdd<Stg_CCI>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_CHAIKIN:
        _result &= StrategyAdd<Stg_Chaikin>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_DEMA:
        _result &= StrategyAdd<Stg_DEMA>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_DPO:
        _result &= StrategyAdd<Stg_DPO>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_DEMARKER:
        _result &= StrategyAdd<Stg_DeMarker>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_ENVELOPES:
        _result &= StrategyAdd<Stg_Envelopes>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_FORCE:
        _result &= StrategyAdd<Stg_Force>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_FRACTALS:
        _result &= StrategyAdd<Stg_Fractals>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_GATOR:
        _result &= StrategyAdd<Stg_Gator>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_HEIKEN_ASHI:
        _result &= StrategyAdd<Stg_HeikenAshi>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_ICHIMOKU:
        _result &= StrategyAdd<Stg_Ichimoku>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_INDICATOR:
        _result &= StrategyAdd<Stg_Indicator>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_MA:
        _result &= StrategyAdd<Stg_MA>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_MA_BREAKOUT:
        _result &= StrategyAdd<Stg_MA_Breakout>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_MA_CROSS_PIVOT:
        _result &= StrategyAdd<Stg_MA_Cross_Pivot>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_MA_CROSS_SHIFT:
        _result &= StrategyAdd<Stg_MA_Cross_Shift>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_MA_CROSS_SUP_RES:
        _result &= StrategyAdd<Stg_MA_Cross_Sup_Res>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_MA_TREND:
        _result &= StrategyAdd<Stg_MA_Trend>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_MACD:
        _result &= StrategyAdd<Stg_MACD>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_MFI:
        _result &= StrategyAdd<Stg_MFI>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_MOMENTUM:
        _result &= StrategyAdd<Stg_Momentum>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_OBV:
        _result &= StrategyAdd<Stg_OBV>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_OSCILLATOR:
        _result &= StrategyAdd<Stg_Oscillator>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_OSCILLATOR_DIVERGENCE:
        _result &= StrategyAdd<Stg_Oscillator_Divergence>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_OSCILLATOR_MULTI:
        _result &= StrategyAdd<Stg_Oscillator_Multi>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_OSCILLATOR_CROSS:
        _result &= StrategyAdd<Stg_Oscillator_Cross>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_OSCILLATOR_CROSS_SHIFT:
        _result &= StrategyAdd<Stg_Oscillator_Cross_Shift>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_OSCILLATOR_CROSS_ZERO:
        _result &= StrategyAdd<Stg_Oscillator_Cross_Zero>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_OSCILLATOR_RANGE:
        _result &= StrategyAdd<Stg_Oscillator_Range>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_OSCILLATOR_TREND:
        _result &= StrategyAdd<Stg_Oscillator_Trend>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_OSMA:
        _result &= StrategyAdd<Stg_OsMA>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_PATTERN:
        _result &= StrategyAdd<Stg_Pattern>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_PINBAR:
        _result &= StrategyAdd<Stg_Pinbar>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_PIVOT:
        _result &= StrategyAdd<Stg_Pivot>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_RSI:
        _result &= StrategyAdd<Stg_RSI>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_RVI:
        _result &= StrategyAdd<Stg_RVI>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_SAR:
        _result &= StrategyAdd<Stg_SAR>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_STDDEV:
        _result &= StrategyAdd<Stg_StdDev>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_STOCHASTIC:
        _result &= StrategyAdd<Stg_Stochastic>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_WPR:
        _result &= StrategyAdd<Stg_WPR>(_tf, _magic_no, _sid, _index);
        break;
      case STRAT_ZIGZAG:
        _result &= StrategyAdd<Stg_ZigZag>(_tf, _magic_no, _sid, _index);
        break;
      default:
        logger.Warning(StringFormat("Unknown strategy: %d", _sid), __FUNCTION_LINE__, GetName());
        break;
    }

    return _result;
  }

  /**
   * Adds strategy to specific timeframe.
   *
   * @param
   *   _tf - timeframe to add the strategy.
   *   _magic_no - unique order identified
   *
   * @return
   *   Returns true if the strategy has been initialized correctly, otherwise false.
   */
  template <typename SClass>
  bool StrategyAdd(ENUM_TIMEFRAMES _tf, long _magic_no = 0, int _type = 0, long _index = 0) {
    bool _result = true;
    _magic_no = _magic_no > 0 ? _magic_no : rand();
    Ref<Strategy> _strat = ((SClass *)NULL).Init(_tf);
    _strat.Ptr().Set<long>(STRAT_PARAM_ID, _magic_no);
    _strat.Ptr().Set<ENUM_TIMEFRAMES>(STRAT_PARAM_TF, _tf);
    _strat.Ptr().Set<int>(STRAT_PARAM_TYPE, _type);
    _strat.Ptr().OnInit();
    strats.Set(_index, _strat);
    return _result;
  }

  /**
   * Gets strategy.
   */
  Ref<Strategy> GetStrategy() {
    Indi_Pivot *_indi = GetIndicator();
    Chart *_chart = (Chart *)_indi;
    int _pp_shift = ::Meta_Pivot_Indi_Pivot_Shift;  // @fixme
    bool _result =
        _indi.GetFlag(INDI_ENTRY_FLAG_IS_VALID, _pp_shift) && _indi.GetFlag(INDI_ENTRY_FLAG_IS_VALID, _pp_shift + 3);
    Ref<Strategy> _strat_ref;
    if (!_result) {
      // Returns false when indicator data is not valid.
      return _strat_ref;
    }
    // IndicatorSignal _signals = _indi.GetSignals(4, _shift);
    IndicatorDataEntry _entry = _indi[_pp_shift + 1];
    float _curr_price = (float)_chart.GetPrice(PRICE_TYPICAL, _pp_shift);
    float _pp = _entry.GetValue<float>((int)INDI_PIVOT_PP);
    float _r1 = _entry.GetValue<float>((int)INDI_PIVOT_R1);
    float _r2 = _entry.GetValue<float>((int)INDI_PIVOT_R2);
    float _r3 = _entry.GetValue<float>((int)INDI_PIVOT_R3);
    float _r4 = _entry.GetValue<float>((int)INDI_PIVOT_R4);
    float _s1 = _entry.GetValue<float>((int)INDI_PIVOT_S1);
    float _s2 = _entry.GetValue<float>((int)INDI_PIVOT_S2);
    float _s3 = _entry.GetValue<float>((int)INDI_PIVOT_S3);
    float _s4 = _entry.GetValue<float>((int)INDI_PIVOT_S4);
    if (_curr_price > _s1 && _curr_price < _r1) {
      // Price value is between S1 and R1 pivot range.
      _strat_ref = strats.GetByKey(0);
    } else if (_curr_price > _s2 && _curr_price < _r2) {
      // Price value is between S2 and R2 pivot range.
      _strat_ref = strats.GetByKey(1);
    } else if (_curr_price > _s3 && _curr_price < _r3) {
      // Price value is between S3 and R3 pivot range.
      _strat_ref = strats.GetByKey(2);
    } else {
      // Price value is between S4 and R4 and beyond pivot range.
      _strat_ref = strats.GetByKey(3);
    }
    return _strat_ref;
  }

  /**
   * Gets price stop value.
   */
  float PriceStop(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0, float _level = 0.0f,
                  short _bars = 4) {
    float _result = 0;
    if (_method == 0) {
      // Ignores calculation when method is 0.
      return (float)_result;
    }
    Ref<Strategy> _strat_ref = GetStrategy();
    if (!_strat_ref.IsSet()) {
      // Returns false when strategy is not set.
      return false;
    }

    _level = _level == 0.0f ? _strat_ref.Ptr().Get<float>(STRAT_PARAM_SOL) : _level;
    _method = _strat_ref.Ptr().Get<int>(STRAT_PARAM_SOM);
    //_shift = _shift == 0 ? _strat_ref.Ptr().Get<int>(STRAT_PARAM_SHIFT) : _shift;
    _result = _strat_ref.Ptr().PriceStop(_cmd, _mode, _method, _level /*, _shift*/);
    return (float)_result;
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method, float _level = 0.0f, int _shift = 0) {
    bool _result = true;
    Ref<Strategy> _strat_ref = GetStrategy();
    if (!_strat_ref.IsSet()) {
      // Returns false when strategy is not set.
      return false;
    }
    _level = _level == 0.0f ? _strat_ref.Ptr().Get<float>(STRAT_PARAM_SOL) : _level;
    _method = _method == 0 ? _strat_ref.Ptr().Get<int>(STRAT_PARAM_SOM) : _method;
    _shift = _shift == 0 ? _strat_ref.Ptr().Get<int>(STRAT_PARAM_SHIFT) : _shift;
    _result &= _strat_ref.Ptr().SignalOpen(_cmd, _method, _level, _shift);
    return _result;
  }

  /**
   * Check strategy's closing signal.
   */
  bool SignalClose(ENUM_ORDER_TYPE _cmd, int _method, float _level = 0.0f, int _shift = 0) {
    bool _result = false;
    _result = SignalOpen(Order::NegateOrderType(_cmd), _method, _level, _shift);
    return _result;
  }
};

#endif  // STG_META_PIVOT_MQH
