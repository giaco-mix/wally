import 'goal.dart';
import 'lazy_portfolio.dart';
import 'pac_calculator.dart';
import 'pac_frequency.dart';
import 'risk_profile.dart';

/// Come l'utente ha impostato il piano: partendo da un capitale obiettivo
/// oppure da un versamento sostenibile.
enum PlanMode {
  targetCapital('Da un obiettivo di capitale'),
  sustainableContribution('Da quanto posso versare');

  const PlanMode(this.label);
  final String label;

  static PlanMode fromName(String? name) => PlanMode.values.firstWhere(
        (m) => m.name == name,
        orElse: () => PlanMode.sustainableContribution,
      );
}

/// Il piano d'investimento dell'utente: obiettivo, orizzonte, versamento,
/// profilo di rischio e lazy portfolio scelto.
class InvestmentPlan {
  const InvestmentPlan({
    this.id,
    required this.goalType,
    this.goalLabel,
    required this.mode,
    this.targetAmount,
    required this.horizonYears,
    required this.monthlyContribution,
    required this.riskProfile,
    required this.lazyPortfolioId,
    this.frequency = PacFrequency.monthly,
    this.initialLump = 0,
  });

  final String? id;
  final GoalType goalType;
  final String? goalLabel;
  final PlanMode mode;
  final double? targetAmount;
  final int horizonYears;

  /// Equivalente mensile del versamento (canonico per i calcoli).
  final double monthlyContribution;
  final RiskProfile riskProfile;
  final String lazyPortfolioId;

  /// Cadenza con cui l'utente versa effettivamente.
  final PacFrequency frequency;

  /// Versamento iniziale una tantum (maxi-canone).
  final double initialLump;

  /// Importo del singolo versamento secondo la cadenza scelta.
  double get installmentAmount =>
      frequency.perInstallment(monthlyContribution);

  LazyPortfolio get lazyPortfolio =>
      LazyPortfolio.byId(lazyPortfolioId) ??
      LazyPortfolio.forProfile(riskProfile);

  /// Valore atteso a fine orizzonte, dato il profilo di rischio.
  double get projectedValue => PacCalculator.futureValue(
        monthly: monthlyContribution,
        years: horizonYears,
        annualReturn: riskProfile.expectedReturn,
        initialLump: initialLump,
      );

  double get totalContributed =>
      monthlyContribution * horizonYears * 12 + initialLump;

  List<ProjectionPoint> get projection => PacCalculator.projection(
        monthly: monthlyContribution,
        years: horizonYears,
        annualReturn: riskProfile.expectedReturn,
        initialLump: initialLump,
      );

  InvestmentPlan copyWith({
    GoalType? goalType,
    String? goalLabel,
    PlanMode? mode,
    double? targetAmount,
    int? horizonYears,
    double? monthlyContribution,
    RiskProfile? riskProfile,
    String? lazyPortfolioId,
    PacFrequency? frequency,
    double? initialLump,
  }) {
    return InvestmentPlan(
      id: id,
      goalType: goalType ?? this.goalType,
      goalLabel: goalLabel ?? this.goalLabel,
      mode: mode ?? this.mode,
      targetAmount: targetAmount ?? this.targetAmount,
      horizonYears: horizonYears ?? this.horizonYears,
      monthlyContribution: monthlyContribution ?? this.monthlyContribution,
      riskProfile: riskProfile ?? this.riskProfile,
      lazyPortfolioId: lazyPortfolioId ?? this.lazyPortfolioId,
      frequency: frequency ?? this.frequency,
      initialLump: initialLump ?? this.initialLump,
    );
  }

  factory InvestmentPlan.fromMap(Map<String, dynamic> map) {
    return InvestmentPlan(
      id: map['id']?.toString(),
      goalType: GoalType.fromName(map['goal_type'] as String?),
      goalLabel: map['goal_label'] as String?,
      mode: PlanMode.fromName(map['mode'] as String?),
      targetAmount: (map['target_amount'] as num?)?.toDouble(),
      horizonYears: (map['horizon_years'] as num).toInt(),
      monthlyContribution: (map['monthly_contribution'] as num).toDouble(),
      riskProfile: RiskProfile.fromName(map['risk_profile'] as String?),
      lazyPortfolioId: map['lazy_portfolio_id'] as String? ?? 'balanced_60_40',
      frequency: PacFrequency.fromName(map['frequency'] as String?),
      initialLump: (map['initial_lump'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toInsert(String userId) {
    return {
      'user_id': userId,
      'goal_type': goalType.name,
      'goal_label': goalLabel,
      'mode': mode.name,
      'target_amount': targetAmount,
      'horizon_years': horizonYears,
      'monthly_contribution': monthlyContribution,
      'risk_profile': riskProfile.name,
      'lazy_portfolio_id': lazyPortfolioId,
      'frequency': frequency.name,
      'initial_lump': initialLump,
    };
  }
}
