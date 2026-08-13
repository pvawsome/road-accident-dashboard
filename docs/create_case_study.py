from reportlab.lib import colors
from reportlab.lib.enums import TA_LEFT
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, KeepTogether

out = "/home/pvawsome/Projects/road-accident-dashboard/docs/road_accident_dashboard_case_study.pdf"
doc = SimpleDocTemplate(out, pagesize=letter, rightMargin=0.48*inch, leftMargin=0.48*inch, topMargin=0.38*inch, bottomMargin=0.35*inch)
styles = getSampleStyleSheet()
styles.add(ParagraphStyle(name="Title2", parent=styles["Title"], fontName="Helvetica-Bold", fontSize=20, leading=22, textColor=colors.HexColor("#123B5D"), spaceAfter=3))
styles.add(ParagraphStyle(name="Sub", parent=styles["Normal"], fontSize=9.2, leading=12, textColor=colors.HexColor("#475569"), spaceAfter=7))
styles.add(ParagraphStyle(name="H", parent=styles["Heading2"], fontName="Helvetica-Bold", fontSize=10.3, leading=12, textColor=colors.HexColor("#0F5B78"), spaceBefore=5, spaceAfter=2))
styles.add(ParagraphStyle(name="Body2", parent=styles["BodyText"], fontSize=8.3, leading=10.4, spaceAfter=2.5, textColor=colors.HexColor("#1F2937")))
styles.add(ParagraphStyle(name="Small", parent=styles["BodyText"], fontSize=7.3, leading=8.8, textColor=colors.HexColor("#475569")))
styles.add(ParagraphStyle(name="Metric", parent=styles["BodyText"], fontName="Helvetica-Bold", fontSize=12, leading=14, alignment=TA_LEFT, textColor=colors.HexColor("#123B5D")))

P = lambda text, style="Body2": Paragraph(text, styles[style])
story = []
story.append(P("UK Road Safety Analytics Dashboard", "Title2"))
story.append(P("Project overview | Pavanraj Parthiban | SQL Server • Python • Power BI", "Sub"))
story.append(P("<b>Business problem</b>", "H"))
story.append(P("Road-safety stakeholders need a repeatable way to understand collision volume, casualty severity, vehicle involvement, environmental conditions, and geographic concentration. This project converts large, multi-table public records into validated reporting that can support prioritization of safety interventions and operational monitoring."))
metrics = [[P("503,475<br/><font size=7>collisions</font>", "Metric"), P("640,522<br/><font size=7>casualties</font>", "Metric"), P("920,692<br/><font size=7>vehicles</font>", "Metric"), P("2020–2024<br/><font size=7>coverage</font>", "Metric")]]
t = Table(metrics, colWidths=[1.72*inch]*4)
t.setStyle(TableStyle([("BACKGROUND", (0,0), (-1,-1), colors.HexColor("#E8F3F7")), ("BOX", (0,0), (-1,-1), 0.4, colors.HexColor("#B7D6DF")), ("INNERGRID", (0,0), (-1,-1), 0.4, colors.white), ("VALIGN", (0,0), (-1,-1), "MIDDLE"), ("LEFTPADDING", (0,0), (-1,-1), 9), ("TOPPADDING", (0,0), (-1,-1), 7), ("BOTTOMPADDING", (0,0), (-1,-1), 7)]))
story += [Spacer(1, 4), t]
story.append(P("<b>Analytical questions</b>", "H"))
story.append(P("How did collision and casualty volume change by year and month? Which severity levels and vehicle categories contributed most? How were records distributed across weather, road-surface, urban/rural, and geographic conditions?"))
story.append(P("<b>Approach and technical implementation</b>", "H"))
story.append(P("Python inspection and validation → cleaned CSV/Parquet outputs → SQL Server staging and typed relational tables → primary/foreign keys and indexes → reporting and summary views → Power BI model, DAX measures, and three dashboard pages. The model separates collision, vehicle, and casualty grain to support reliable filtering and avoid unnecessary many-to-many relationships."))
story.append(P("<b>Validated data quality</b>", "H"))
quality = [[P("✓ 0 duplicate collision keys", "Body2"), P("✓ 0 duplicate casualty keys", "Body2"), P("✓ 0 duplicate vehicle keys", "Body2")], [P("✓ 0 casualties without matching collisions", "Body2"), P("✓ 0 vehicles without matching collisions", "Body2"), P("✓ Row counts reconciled to source tables", "Body2")]]
qt = Table(quality, colWidths=[2.29*inch]*3)
qt.setStyle(TableStyle([("BACKGROUND", (0,0), (-1,-1), colors.HexColor("#F4F8F9")), ("BOX", (0,0), (-1,-1), 0.3, colors.HexColor("#D4E2E6")), ("INNERGRID", (0,0), (-1,-1), 0.3, colors.white), ("VALIGN", (0,0), (-1,-1), "TOP"), ("LEFTPADDING", (0,0), (-1,-1), 6), ("TOPPADDING", (0,0), (-1,-1), 4), ("BOTTOMPADDING", (0,0), (-1,-1), 2)]))
story.append(qt)
story.append(P("<b>Selected findings</b>", "H"))
story.append(P("• Collision volume peaked in 2022 at 106,004, then declined to 100,927 in 2024 (−4.8% from the peak).<br/>• Slight injuries were the largest casualty-severity group; fatal and serious outcomes remain important for prioritization.<br/>• Cars were associated with the highest casualty counts among vehicle categories.<br/>• Fine weather/no high winds and dry road surfaces were the most frequently recorded conditions.<br/>• Urban areas represented the largest casualty share, while the geographic page highlights concentration patterns across Great Britain."))
story.append(P("<b>Decision value</b>", "H"))
story.append(P("The report gives stakeholders a consistent baseline for monitoring trends and identifying where deeper investigation may be warranted. It preserves unknown and missing categories rather than silently excluding them, making the analysis more transparent and reproducible."))
story.append(P("<b>Limitations and next steps</b>", "H"))
story.append(P("The records describe reported collisions, not total road risk or causal effects. Rounded coordinate grids limit geographic precision, and the exported PDF reflects its saved filter state. Future improvements include a date dimension, time-intelligence measures, a true density map, and automated refresh/data-quality reporting."))
story.append(Spacer(1, 4))
story.append(P("Repository: github.com/pvawsome/road-accident-dashboard  |  Deliverables: SQL scripts, Python preparation/validation, Power BI export, screenshots, and documentation", "Small"))
doc.build(story)
print(out)
