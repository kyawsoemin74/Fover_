from pathlib import Path
rels=[
 'lib/features/auth/providers/auth_provider.dart',
 'lib/features/home/presentation/home_page.dart',
 'lib/features/home/presentation/widgets/home_top_section.dart',
 'lib/features/auth/domain/models/auth_user.dart',
]
for rel in rels:
    print('===', rel, '===')
    p=Path(rel)
    lines=p.read_text(encoding='utf-8').splitlines()
    if rel.endswith('auth_provider.dart'):
        start, end = 1, 220
    elif rel.endswith('home_page.dart'):
        start, end = 140, 210
    elif rel.endswith('home_top_section.dart'):
        start, end = 1, 110
    else:
        start, end = 1, 80
    for i in range(start, min(end, len(lines))+1):
        print(f'{i}: {lines[i-1]}')
    print()
