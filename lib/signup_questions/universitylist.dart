var universities = [
  '가천길대학',
  '가톨릭상지대학교',
  '강동대학교',
  '강릉영동대학교',
  '강원관광대학',
  '강원도립대학',
  '거제대학교',
  '경기과학기술대학교',
  '경남도립거창대학',
  '경남도립남해대학',
  '경남정보대학교',
  '경민대학교',
  '경복대학교',
  '경북과학대학교',
  '경북도립대학교',
  '경북전문대학교',
  '경산1대학교',
  '경원전문대학',
  '경인여자대학교',
  '계명문화대학교',
  '계원예술대학교',
  '고구려대학교',
  '광양보건대학교',
  '광주보건대학교',
  '구미대학교',
  '구세군사관학교',
  '국제대학교',
  '군산간호대학교',
  '군장대학교',
  '기독간호대학교',
  '김천과학대학',
  '김천대학',
  '김포대학교',
  '김해대학교',
  '농협대학교',
  '대경대학교',
  '대구공업대학교',
  '대구과학대학교',
  '대구미래대학교',
  '대구보건대학교',
  '대덕대학교',
  '대동대학교',
  '대림대학교',
  '대원대학교',
  '대전보건대학교',
  '동강대학교',
  '동남보건대학교',
  '동명대학',
  '동부산대학교',
  '동서울대학교',
  '동아방송예술대학교',
  '동아인재대학교',
  '동양미래대학교',
  '동우대학',
  '동원과학기술대학교',
  '동원대학교',
  '동의과학대학교',
  '동주대학교',
  '두원공과대학교',
  '마산대학교',
  '명지전문대학',
  '목포과학대학교',
  '문경대학교',
  '배화여자대학교',
  '백석문화대학교',
  "백석예술대학교",
  '백제예술대학교',
  '벽성대학',
  '부산경상대학교',
  '부산과학기술대학교',
  '부산여자대학교',
  '부산예술대학교',
  '부천대학교',
  '삼육보건대학',
  '삼육의명대학',
  '상지영서대학교',
  '서라벌대학교',
  '서영대학교',
  '서울보건대학',
  '서울여자간호대학교',
  '서울예술대학교',
  '서일대학교',
  '서정대학교',
  '서해대학',
  '선린대학교',
  '성덕대학교',
  '성심외국어대학',
  '세경대학교',
  '송곡대학교',
  '송원대학',
  '송호대학교',
  '수성대학교',
  '수원과학대학교',
  '수원여자대학교',
  '순천제일대학',
  '숭의여자대학교',
  '신구대학교',
  '신성대학교',
  '신안산대학교',
  '신흥대학교',
  '아주자동차대학',
  '안동과학대학교',
  '안산대학교',
  '여주대학교',
  '연성대학교',
  '연암공과대학교',
  '영남외국어대학',
  '영남이공대학교',
  '영진사이버대학',
  '영진전문대학',
  '오산대학교',
  '용인송담대학교',
  '우송공업대학',
  '우송정보대학',
  '울산과학대학교',
  '웅지세무대학',
  '원광보건대학교',
  '원주대학',
  '유한대학교',
  '인덕대학교',
  '인천재능대학교',
  '인천전문대학',
  '인하공업전문대학',
  '장안대학교',
  '적십자간호대학',
  '전남과학대학교',
  '전남도립대학교',
  '전북과학대학교',
  '전주기전대학',
  '전주비전대학교',
  '제주관광대학교',
  '제주산업정보대학',
  '제주한라대학교',
  '조선간호대학교',
  '조선이공대학교',
  '진주보건대학교',
  '창신대학',
  '창원문성대학',
  '천안연암대학',
  '청강문화산업대학교',
  '청암대학교',
  '춘해보건대학교',
  '충남도립청양대학',
  '충북도립대학',
  '충북보건과학대학교',
  '충청대학교',
  '포항대학교',
  '한국골프대학',
  '한국관광대학교',
  '한국농수산대학',
  '한국복지대학교',
  '한국복지사이버대학',
  '한국승강기대학교',
  '한국영상대학교',
  '한국정보통신기능대학',
  '한국철도대학',
  '한국폴리텍',
  '한림성심대학교',
  '한양여자대학교',
  '한영대학',
  '혜전대학',
  '혜천대학교',
  '가야대학교',
  '가천대학교',
  '가천의과학대학교',
  '가톨릭대학교',
  '감리교신학대학교',
  '강남대학교',
  '강릉원주대학교',
  '강원대학교',
  '건국대학교',
  '건국대학교(글로컬)',
  '건양대학교',
  '건양사이버대학교',
  '경기대학교',
  '경남과학기술대학교',
  '경남대학교',
  '경동대학교',
  '경북대학교',
  '경북외국어대학교',
  '경상대학교',
  '경성대학교',
  '경운대학교',
  '경운대학교(산업대)',
  '경인교육대학교',
  '경일대학교',
  '경주대학교',
  '경희대학교',
  '경희사이버대학교',
  '계명대학교',
  '고려대학교',
  '고려대학교(세종)',
  '고려사이버대학교',
  '고신대학교',
  '공주교육대학교',
  '공주대학교',
  '가톨릭관동대학교',
  '광신대학교',
  '광운대학교',
  '광주가톨릭대학교',
  'GIST',
  '광주교육대학교',
  '광주대학교',
  '광주대학교(산업대)',
  '광주여자대학교',
  '국민대학교',
  '국제사이버대학교',
  '군산대학교',
  '그리스도대학교',
  '극동대학교',
  '글로벌사이버대학교',
  '금강대학교',
  '금오공과대학교',
  '김천대학교',
  '꽃동네대학교',
  '나사렛대학교',
  '남부대학교',
  '남서울대학교',
  '단국대학교',
  '대구가톨릭대학교',
  'DGIST',
  '대구교육대학교',
  '대구대학교',
  '대구사이버대학교',
  '대구예술대학교',
  '대구외국어대학교',
  '대구한의대학교',
  '대신대학교',
  '대전가톨릭대학교',
  '대전대학교',
  '대전신학교',
  '대전신학대학교',
  '대진대학교',
  '덕성여자대학교',
  '동국대학교',
  '동국대학교(경주)',
  '동덕여자대학교',
  '동명대학교',
  '동명정보대학교',
  '동서대학교',
  '동신대학교',
  '동아대학교',
  '동양대학교',
  '동의대학교',
  '디지털서울문화예술대학교',
  '루터대학교',
  '명지대학교',
  '목원대학교',
  '목포가톨릭대학교',
  '목포대학교',
  '목포해양대학교',
  '배재대학교',
  '백석대학교',
  '부경대학교',
  '부산가톨릭대학교',
  '부산교육대학교',
  '부산대학교',
  '부산디지털대학교',
  '부산외국어대학교',
  '부산장신대학교',
  '사이버한국외국어대학교',
  '삼육대학교',
  '상명대학교',
  '상명대학교(천안)',
  '상주대학교',
  '상지대학교',
  '서강대학교',
  '서경대학교',
  '서남대학교',
  '서울과학기술대학교',
  '서울과학기술대학교(산업대)',
  '서울교육대학교',
  '서울기독대학교',
  '서울대학교',
  '서울디지털대학교',
  '서울사이버대학교',
  '서울시립대학교',
  '서울신학대학교',
  '서울여자대학교',
  '서울장신대학교',
  '서원대학교',
  '선문대학교',
  '성결대학교',
  '성공회대학교',
  '성균관대학교',
  '성신여자대학교',
  '세명대학교',
  '세종대학교',
  '세종사이버대학교',
  '세한대학교',
  '송원대학교',
  '수원가톨릭대학교',
  '수원대학교',
  '숙명여자대학교',
  '순복음총회신학교',
  '순천대학교',
  '순천향대학교',
  '숭실대학교',
  '숭실사이버대학교',
  '신경대학교',
  '신라대학교',
  '아세아연합신학대학교',
  '아주대학교',
  '안동대학교',
  '안양대학교',
  '연세대학교',
  '연세대학교(원주)',
  '열린사이버대학교',
  '영남대학교',
  '영남신학대학교',
  '유원대학교',
  '영산대학교',
  '영산대학교(산업대)',
  '영산선학대학교',
  '예수대학교',
  '예원예술대학교',
  '용인대학교',
  '우석대학교',
  '우송대학교',
  '우송대학교(산업대)',
  'UNIST',
  '울산대학교',
  '원광대학교',
  '원광디지털대학교',
  '위덕대학교',
  '을지대학교',
  '이화여자대학교',
  '인제대학교',
  '인천가톨릭대학교',
  '인천대학교',
  '인하대학교',
  '장로회신학대학교',
  '전남대학교',
  '전북대학교',
  '전주교육대학교',
  '전주대학교',
  '정석대학',
  '제주교육대학교',
  '제주국제대학교',
  '제주대학교',
  '조선대학교',
  '중부대학교',
  '중앙대학교',
  '중앙대학교(안성)',
  '중앙승가대학교',
  '중원대학교',
  '진주교육대학교',
  '진주산업대학교(산업대)',
  '차의과학대학교',
  '창신대학교',
  '창원대학교',
  '청운대학교',
  '청주교육대학교',
  '청주대학교',
  '초당대학교',
  '초당대학교(산업대)',
  '총신대학교',
  '추계예술대학교',
  '춘천교육대학교',
  '충남대학교',
  '충북대학교',
  '침례신학대학교',
  '칼빈대학교',
  '탐라대학교',
  '평택대학교',
  'POSTECH',
  '한경대학교',
  '한경대학교(산업대)',
  '카이스트(KAIST)',
  '한국교원대학교',
  '한국교통대학교',
  '한국교통대학교(산업대)',
  '한국국제대학교',
  '한국기술교육대학교',
  '한국방송통신대학교',
  '한국산업기술대학교',
  '한국산업기술대학교(산업대)',
  '한국성서대학교',
  '한국예술종합학교',
  '한국외국어대학교',
  '한국전통문화대학교',
  '한국체육대학교',
  '한국항공대학교',
  '한국해양대학교',
  '한남대학교',
  '한동대학교',
  '한라대학교',
  '한려대학교',
  '한려대학교(산업대)',
  '한림대학교',
  '한민학교',
  '한밭대학교',
  '한밭대학교(산업대)',
  '한북대학교',
  '한서대학교',
  '한성대학교',
  '한세대학교',
  '한신대학교',
  '한양대학교',
  '한양대학교(ERICA)',
  '한양사이버대학교',
  '한영신학대학교',
  '한일장신대학교',
  '한중대학교',
  '협성대학교',
  '호남대학교',
  '호남신학대학교',
  '호서대학교',
  '호원대학교',
  '홍익대학교',
  '홍익대학교(세종)',
  '화신사이버대학교'
];

var university_domain = [
  'gachon.ac.kr',
  'csj.ac.kr',
  'gangdong.ac.kr',
  'gyc.ac.kr',
  'kt.ac.kr',
  'gw.ac.kr',
  'koje.ac.kr',
  'gtec.ac.kr',
  'gc.ac.kr',
  'namhae.ac.kr',
  'kit.ac.kr',
  'kyungmin.ac.kr',
  'kbu.ac.kr',
  'kbsc.ac.kr',
  'gpc.ac.kr',
  'kbc.ac.kr',
  'gs.ac.kr',
  'kwc.ac.kr',
  'kic.ac.kr',
  'kmcu.ac.kr',
  'kaywon.ac.kr',
  'kgrc.ac.kr',
  'kwangyang.ac.kr',
  'ghu.ac.kr',
  'gumi.ac.kr',
  'saotc.ac.kr',
  'kookje.ac.kr',
  'kcn.ac.kr',
  'kunjang.ac.kr',
  'ccn.ac.kr',
  'kcs.ac.kr',
  'gimcheon.ac.kr',
  'kimpo.ac.kr',
  'gimhae.ac.kr',
  'nonghyup.ac.kr',
  'tk.ac.kr',
  'ttc.ac.kr',
  'tsu.ac.kr',
  'dfc.ac.kr',
  'dhc.ac.kr',
  'ddu.ac.kr',
  'daedong.ac.kr',
  'daelim.ac.kr',
  'daewon.ac.kr',
  'hit.ac.kr',
  'dkc.ac.kr',
  'dongnam.ac.kr',
  'tu.ac.kr',
  'dpc.ac.kr',
  'dsc.ac.kr',
  'dima.ac.kr',
  'dongac.ac.kr',
  'dongyang.ac.kr',
  'duc.ac.kr',
  'dist.ac.kr',
  'tw.ac.kr',
  'dit.ac.kr',
  'dongju.ac.kr',
  'doowon.ac.kr',
  'masan.ac.kr',
  'mjc.ac.kr',
  'mokpo-c.ac.kr',
  'mkc.ac.kr',
  'baewha.ac.kr',
  'bscu.ac.kr',
  "bau.ac.kr",
  'paekche.ac.kr',
  'bs.ac.kr',
  'bsks.ac.kr',
  'bist.ac.kr',
  'bwc.ac.kr',
  'busanarts.ac.kr',
  'bc.ac.kr',
  'shu.ac.kr',
  'syu.ac.kr',
  'sy.ac.kr',
  'sorabol.ac.kr',
  'seoyeong.ac.kr',
  'shjc.ac.kr',
  'snjc.ac.kr',
  'seoularts.ac.kr',
  'seoil.ac.kr',
  'seojeong.ac.kr',
  'sohae.ac.kr',
  'sunlin.ac.kr',
  'sdc.ac.kr',
  'sungsim.ac.kr',
  'saekyung.ac.kr',
  'songgok.ac.kr',
  'songwon.ac.kr',
  'songho.ac.kr',
  'sc.ac.kr',
  'ssc.ac.kr',
  'swc.ac.kr',
  'suncheon.ac.kr',
  'sewc.ac.kr',
  'shingu.ac.kr',
  'shinsung.ac.kr',
  'sau.ac.kr',
  'shc.ac.kr',
  'motor.ac.kr',
  'asc.ac.kr',
  'ansan.ac.kr',
  'yit.ac.kr',
  'yeonsung.ac.kr',
  'yc.ac.kr',
  'yflc.ac.kr',
  'ync.ac.kr',
  'ycc.ac.kr',
  'yjc.ac.kr',
  'osan.ac.kr',
  'ysc.ac.kr',
  'wst.ac.kr',
  'wsi.ac.kr',
  'uc.ac.kr',
  'wat.ac.kr',
  'wkhc.ac.kr',
  'wonju.ac.kr',
  'yuhan.ac.kr',
  'induk.ac.kr',
  'jeiu.ac.kr',
  'icc.ac.kr',
  'itc.ac.kr',
  'jangan.ac.kr',
  'cau.ac.kr',
  'chunnam-c.ac.kr',
  'dorip.ac.kr',
  'jbsc.ac.kr',
  'jk.ac.kr',
  'jvision.ac.kr',
  'ctc.ac.kr',
  'jeju.ac.kr',
  'chu.ac.kr',
  'cnc.ac.kr',
  'cst.ac.kr',
  'jhc.ac.kr',
  'csc.ac.kr',
  'cmu.ac.kr',
  'yonam.ac.kr',
  'chungkang.academy',
  'scjc.ac.kr',
  'ch.ac.kr',
  'cyc.ac.kr',
  'cpu.ac.kr',
  'chsu.ac.kr',
  'ok.ac.kr',
  'pohang.ac.kr',
  'kg.ac.kr',
  'ktc.ac.kr',
  'af.ac.kr',
  'hanrw.ac.kr',
  'corea.ac.kr',
  'klc.ac.kr',
  'pro.ac.kr',
  'icpc.ac.kr',
  'krc.ac.kr',
  'kopo.ac.kr',
  'hsc.ac.kr',
  'hywoman.ac.kr',
  'hanyeong.ac.kr',
  'hj.ac.kr',
  'hu.ac.kr',
  'kaya.ac.kr',
  'gachon.ac.kr',
  'gachon.ac.kr',
  'catholic.ac.kr',
  'mtu.ac.kr',
  'kangnam.ac.kr',
  'gwnu.ac.kr',
  'kangwon.ac.kr',
  'konkuk.ac.kr',
  'kku.ac.kr',
  'konyang.ac.kr',
  'kycu.ac.kr',
  'kyonggi.ac.kr',
  'gntech.ac.kr',
  'hanma.kr',
  'k1.ac.kr',
  'knu.ac.kr',
  'kufs.ac.kr',
  'gnu.ac.kr',
  'ks.ac.kr',
  'ikw.ac.kr',
  'ikw.ac.kr',
  't.ginue.ac.kr',
  'kiu.kr',
  'gju.ac.kr',
  'khu.ac.kr',
  'khcu.ac.kr',
  'kmu.ac.kr',
  'korea.ac.kr',
  'korea.ac.kr',
  'cuk.edu',
  'kosin.ac.kr',
  'gjue.ac.kr',
  'smail.kongju.ac.kr',
  'cku.ac.kr',
  'kwangshin.ac.kr',
  'kw.ac.kr',
  'kjcatholic.ac.kr',
  'gist.ac.kr',
  'gnue.ac.kr',
  'gwangju.ac.kr',
  'gwangju.ac.kr',
  'kwu.ac.kr',
  'kookmin.ac.kr',
  'gcu.ac',
  'kunsan.ac.kr',
  'kcu.ac.kr',
  'kdu.ac.kr',
  'global.ac.kr',
  'ggu.ac.kr',
  'kumoh.ac.kr',
  'gimcheon.ac.kr',
  'kkot.ac.kr',
  'kornu.ac.kr',
  'nambu.ac.kr',
  'nsu.ac.kr',
  'dankook.ac.kr',
  'cu.ac.kr',
  'dgist.ac.kr',
  'dnue.ac.kr',
  'daegu.ac.kr',
  'dcu.ac.kr',
  'dgau.ac.kr',
  'dufs.ac.kr',
  'dhu.ac.kr',
  'daeshin.ac.kr',
  'dcatholic.ac.kr',
  'edu.dju.ac.kr',
  'daejeon.ac.kr',
  'daejeon.ac.kr',
  'daejin.ac.kr',
  'duksung.ac.kr',
  'dongguk.edu',
  'dongguk.ac.kr',
  'dongduk.ac.kr',
  'tu.ac.kr',
  'tu.ac.kr',
  'dongseo.ac.kr',
  'dsu.kr',
  'donga.ac.kr',
  'dyu.ac.kr',
  'deu.ac.kr',
  'scau.ac.kr',
  'ltu.ac.kr',
  'mju.ac.kr',
  'mokwon.ac.kr',
  'mcu.ac.kr',
  'mokpo.ac.kr',
  'mmu.ac.kr',
  'pcu.ac.kr',
  'bu.ac.kr',
  'pukyong.ac.kr',
  'cup.ac.kr',
  'bnue.ac.kr',
  'pusan.ac.kr',
  'bdu.ac.kr',
  'office.bufs.ac.kr',
  'bpu.ac.kr',
  'cufs.ac.kr',
  'syuin.ac.kr',
  'sangmyung.kr',
  'sangmyung.kr',
  'knu.ac.kr',
  'sangji.ac.kr',
  'sogang.ac.kr',
  'skuniv.ac.kr',
  'seonam.ac.kr',
  'seoultech.ac.kr',
  'seoultech.ac.kr',
  'snue.ac.kr',
  'scu.ac.kr',
  'snu.ac.kr',
  'sdu.ac.kr',
  'iscu.ac.kr',
  'uos.ac.kr',
  'stu.ac.kr',
  'swu.ac.kr',
  'sjs.ac.kr',
  'seowon.ac.kr',
  'sunmoon.ac.kr',
  'sungkyul.ac.kr',
  'skhu.ac.kr',
  'g.skku.edu',
  'sungshin.ac.kr',
  'semyung.ac.kr',
  'sju.ac.kr',
  'sjcu.ac.kr',
  'sehan.ac.kr',
  'songwon.ac.kr',
  'suwoncatholic.ac.kr',
  'suwon.ac.kr',
  'sookmyung.ac.kr',
  'kcc.ac.kr',
  's.scnu.ac.kr',
  'sch.ac.kr',
  'soongsil.ac.kr',
  'kcu.ac',
  'sgu.ac.kr',
  'silla.ac.kr',
  'acts.ac.kr',
  'ajou.ac.kr',
  'anu.ac.kr',
  'ayum.anyang.ac.kr',
  'yonsei.ac.kr',
  'yonsei.ac.kr',
  'ocu.ac.kr',
  'ynu.ac.kr',
  'ytus.ac.kr',
  'u1.ac.kr',
  'ysu.ac.kr',
  'ysu.ac.kr',
  'youngsan.ac.kr',
  'jesus.ac.kr',
  'yewon.ac.kr',
  'yiu.ac.kr',
  'woosuk.ac.kr',
  'wsu.ac.kr',
  'wsu.ac.kr',
  'unist.ac.kr',
  'ulsan.ac.kr',
  'wonkwang.ac.kr',
  'wdu.ac.kr',
  'uu.ac.kr',
  'eulji.ac.kr',
  'ewhain.net',
  'inje.ac.kr',
  'iccu.ac.kr',
  'inu.ac.kr',
  'inha.edu',
  'pcts.ac.kr',
  'jnu.ac.kr',
  'jbnu.ac.kr',
  'jnue.kr',
  'jj.ac.kr',
  'jit.ac.kr',
  'jejue.ac.kr',
  'jeju.ac.kr',
  'jejunu.ac.kr',
  'chosun.kr',
  'jmail.ac.kr',
  'cau.ac.kr',
  'cau.ac.kr',
  'sangha.ac.kr',
  'jwu.ac.kr',
  'cue.ac.kr',
  'gntech.ac.kr',
  'cha.ac.kr',
  'cs.ac.kr',
  'changwon.ac.kr',
  'chungwoon.ac.kr',
  'cje.ac.kr',
  'cju.ac.kr',
  'chodang.ac.kr',
  'chodang.ac.kr',
  'chongshin.ac.kr',
  'chugye.ac.kr',
  'cnue.ac.kr',
  'cnu.ac.kr',
  'chungbuk.ac.kr',
  'kbtus.ac.kr',
  'calvin.ac.kr',
  'tnu.ac.kr',
  'ptu.ac.kr',
  'postech.ac.kr',
  'hknu.ac.kr',
  'hknu.ac.kr',
  'kaist.ac.kr',
  'knue.ac.kr',
  'ut.ac.kr',
  'ut.ac.kr',
  'iuk.ac.kr',
  'koreatech.ac.kr',
  'knou.ac.kr',
  'kpu.ac.kr',
  'kpu.ac.kr',
  'bible.ac.kr',
  'karts.ac.kr',
  'hufs.ac.kr',
  'nuch.ac.kr',
  'knsu.ac.kr',
  'kau.kr',
  'kmou.ac.kr',
  'hannam.ac.kr',
  'handong.edu',
  'halla.ac.kr',
  'hanlyo.ac.kr',
  'hanlyo.ac.kr',
  'hallym.ac.kr',
  'hanmin.ac.kr',
  'hanbat.ac.kr',
  'hanbat.ac.kr',
  'hanbuk.ac.kr',
  'hanseo.ac.kr',
  'hansung.ac.kr',
  'uohs.ac.kr',
  'hs.ac.kr',
  'hanyang.ac.kr',
  'hanyang.ac.kr',
  'hycu.ac.kr',
  'hytu.ac.kr',
  'hanil.ac.kr',
  'hanzhong.ac.kr',
  'uhs.ac.kr',
  'honam.ac.kr',
  'htus.ac.kr',
  'hoseo.edu',
  'howon.ac.kr',
  'g.hongik.ac.kr',
  'g.hongik.ac.kr',
  'hscu.ac.kr'
];
