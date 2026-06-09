# AWS × GCP Multi-Cloud Infrastructure Project

> AWS 3-Tier 웹 서비스와 GCP Cloud SQL을 HA VPN + BGP로 사설 연결한 멀티클라우드 인프라 구축

## 개요

| 항목 | 내용 |
|------|------|
| **기간** | 2026.06 |
| **유형** | 팀 프로젝트 |
| **팀 구성** | 김동진 · 이영훈 · 장규혁 · 정성현 |
| **구성 방식** | AWS는 Terraform(IaC), GCP는 콘솔로 구축 후 VPN 연결 |
| **역할** | 팀장 — AWS 인프라 구축 및 VPN 연동 구성 |

### 목표 / 방식 / 결과

| 구분 | 내용 |
|------|------|
| **목표** | AWS 3-Tier 웹 서비스(web/was/db)를 멀티클라우드로 확장 |
| **방식** | AWS는 Terraform으로, GCP는 콘솔로 구축. 두 VPC를 HA VPN + BGP로 사설 연결 |
| **결과** | `db.cloud.local`을 GCP Cloud SQL 비공개 IP로 전환 → AWS Bastion에서 사설망 mysql 접속 검증 |

## 핵심 개념

| 개념 | 설명 |
|------|------|
| **멀티클라우드** | 두 개 이상의 클라우드(AWS, GCP)를 함께 사용해 각 클라우드의 강점을 활용하고 종속성을 줄이는 전략 |
| **HA VPN** | 고가용성 VPN. 터널을 이중화하여 한쪽 터널 장애 시에도 연결을 유지 |
| **BGP** | 동적 라우팅 프로토콜. 두 클라우드 라우터가 서로 경로 정보를 자동 교환해 사설 통신 경로를 학습 |
| **사설 DNS** | `db.cloud.local` 같은 내부 도메인을 비공개 IP로 해석하여 외부 노출 없이 DB에 접근 |

## 생성 리소스

### AWS (Terraform · IaC)

| 분류 | 리소스 |
|------|--------|
| **네트워크** | VPC historynet(10.0.0.0/16), IGW, 서브넷 8개(public/web/was/db × 2AZ), NAT GW 2, EIP 3, 라우팅 테이블 3 |
| **컴퓨팅** | Bastion(10.0.0.10), Web a/b(Nginx 리버스 프록시), WAS a/b(Flask) — EC2 5대 |
| **DB / 로드밸런서** | RDS MySQL 8.0(+ Subnet Group), ALB(web-alb, 공인), NLB(was-nlb, 내부) |
| **보안 / 키 / DNS** | SG 7종, Key Pair(historykey), Route53 cloud.local + db/was 레코드 |
| **VPN** | Customer GW ×2(gcp-gw1/2), Virtual Private GW, Site-to-Site VPN ×2(터널 4) |
| **라우팅** | 라우팅 테이블 전파(propagation) 활성화 |
| **DNS** | db.cloud.local CNAME → A 레코드 변경 (검증 단계) |

### GCP (콘솔)

| 분류 | 리소스 |
|------|--------|
| **네트워크** | VPC historynet, 서브넷 historynet-seoul(10.200.1.0/24), 방화벽 규칙 |
| **VPN / 라우팅** | Cloud Router(ASN 65000), HA VPN GW(aws-vpn), Peer GW(aws-gw), VPN 터널 ×4, BGP 세션 ×4 |
| **컴퓨팅** | gcp-bastion (Rocky Linux) |
| **DB** | Cloud SQL MySQL 8.0(비공개 IP), DB/user history |
| **피어링** | servicenetworking 비공개 서비스 액세스, 커스텀 경로 가져오기/내보내기 |

## 구현 순서

1. **AWS 인프라 구축 (Terraform)** — VPC, 서브넷, EC2(3-tier), RDS, ALB/NLB, VPN GW
2. **GCP 인프라 구축 (콘솔)** — VPC, Cloud SQL, Cloud Router, HA VPN GW
3. **VPN 연결** — AWS Site-to-Site VPN ↔ GCP HA VPN, 터널 4개 구성
4. **BGP 라우팅** — Cloud Router(ASN 65000)와 AWS VGW 간 BGP 세션으로 경로 자동 교환
5. **사설 DNS 전환** — `db.cloud.local`을 Cloud SQL 비공개 IP로 전환
6. **검증** — AWS Bastion에서 GCP Cloud SQL로 사설망 mysql 접속 확인

## 검증 결과

```bash
# AWS Bastion에서 GCP Cloud SQL로 사설망 접속
mysql -h db.cloud.local -u history -p
# → VPN 터널 + BGP 경로를 통해 GCP Cloud SQL(비공개 IP)에 접속 성공
```

- AWS ↔ GCP HA VPN 터널 4개 + BGP 세션 4개 정상 연결 확인
- 라우팅 테이블 전파로 양 클라우드 사설 대역 경로 자동 학습 확인
- `db.cloud.local` 사설 도메인을 통한 크로스 클라우드 DB 접속 검증 완료

## 설계 포인트

| 항목 | 내용 |
|------|------|
| **VPN 이중화** | 터널 4개 + BGP 세션 4개로 구성하여 일부 터널 장애 시에도 연결 유지 |
| **IaC vs 콘솔** | AWS는 Terraform으로 재현성·버전관리 확보, GCP는 콘솔로 구성하며 양쪽 워크플로우 모두 경험 |
| **사설 통신** | DB를 공인 IP로 노출하지 않고 VPN 사설 경로로만 접근하도록 구성하여 보안 강화 |

## 자료

[Multi-Cloud Project HISTORY.pdf](./docs/1_history_multi-cloud.pdf)
