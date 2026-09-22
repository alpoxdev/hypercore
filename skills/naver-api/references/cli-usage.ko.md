# CLI 사용법

**읽기 조건**: CLI를 설치하거나 자격 증명을 설정하거나 네이버 API HUB 명령을 만들기 전에 읽습니다.

## 설치

Node.js 20 이상이 필요합니다.

```sh
node --version
npm install --global @kood/naver-api-cli
naver-api --help
```

`naver-api`가 이미 있으면 다시 설치하지 않습니다. 패키지를 설치할 수 없으면 위 명령을 제공하고 API 작업 전에 중단합니다. 소스 트리 명령이나 다른 패키지로 몰래 대체하지 않습니다.

## 자격 증명

CLI의 숨김 대화형 프롬프트를 사용합니다.

```sh
naver-api config set
naver-api config validate
```

사용자가 제어하는 비대화형 환경에서는 다음 형식의 자격 증명을 stdin으로 보낼 수 있습니다.

```yaml
apiKeyId: your-api-key-id
apiKey: your-api-key
```

```sh
naver-api config set --stdin < credentials.yaml
```

저장소 안에 `credentials.yaml`을 만들지 않습니다. 비밀 값을 명령 인자에 넣거나 echo하지 않습니다. `config show`는 값을 마스킹하고, `config validate`는 네트워크 요청 없이 형식만 검사합니다.

## 명령

```text
naver-api [--json] config set [--stdin]
naver-api [--json] config show
naver-api [--json] config path
naver-api [--json] config validate
naver-api [--json] config delete
naver-api [--json] trends --input <file>
naver-api [--json] shopping-insight categories --input <file>
naver-api [--json] shopping-insight keywords --input <file>
naver-api [--json] search <type> <query> [--display <count>] [--start <index>] [--sort <sort>] [--filter <filter>] [--format json]
```

stdin 입력에는 `--input=-`처럼 `=`를 포함한 형식을 사용합니다. `--input -`는 CLI 파서가 값을 누락한 것으로 처리하므로 사용하지 않습니다.

지원 검색 유형은 `blog`, `news`, `cafearticle`, `kin`, `local`, `encyc`, `webkr`, `image`, `adult`, `errata`입니다. `shop`, `book`, `doc`는 폐기되어 지원하지 않습니다.

트렌드 입력은 YAML 또는 JSON을 받고 `startDate`, `endDate`, `timeUnit`과 작업별 그룹 필드 `keywordGroups`, `category`, `keyword`를 사용합니다. 정확한 요청 스키마는 패키지 README 또는 `naver-api --help`에서 확인하고 그룹 값을 추측하지 않습니다.

## 출력과 실패 처리

결정적인 파싱에는 `--json`을 사용합니다. 성공 시 stdout에 `{ "ok": true, "command": "...", "data": ... }` 형태 문서 하나를 씁니다. 실패 시 stdout 없이 stderr에만 씁니다.

| 종료 | 의미 | 조치 |
|---:|---|---|
| 2 | 사용법 | 입력을 고치고 검증 후 한 번만 재시도합니다. |
| 3 | 설정 | 로컬 설정을 고치고 `config validate` 후 한 번만 재시도합니다. |
| 4 | 인증 | 사용자에게 자격 증명 확인을 요청하고 자동 재시도하지 않습니다. |
| 5 | 사용량 제한 | 제한을 보고하고 중단합니다. |
| 6 | 상위 API | 상위 API 실패를 보고하고 중단합니다. |
| 7 | 네트워크/시간 초과 | 네트워크 상태 또는 시간 초과를 보고하고 중단합니다. |

요청 제한 시간은 15초입니다. 트렌드 비율은 반환된 비교 그룹 내 최댓값이 100인 상대 정규화 지수이며 검색량이 아닙니다.

## Sources

> 저장소 로컬 출처만 사용합니다. `cli/packages/naver-api/README.md`와 `cli/packages/naver-api/package.json`을 이 문서와 대조해 다시 읽었고 확인 2026-09-21.

위 파일을 바탕으로 하며 2026-07-29에 최초 검토했습니다. 패키지 버전 또는 명령 표면이 바뀌면 해당 파일을 다시 확인합니다.
