import xmlm

pub fn main() {
  xmlm.from_string(xml)
  |> xmlm.with_encoding(xmlm.Utf8)
  |> xmlm.signals
}

const xml = "<?xml version=\"1.0\"?>
<!DOCTYPE PubmedArticleSet PUBLIC \"-//NLM//DTD PubMedArticle, 1st January 2024//EN\" \"https://dtd.nlm.nih.gov/ncbi/pubmed/out/pubmed_240101.dtd\">
<PubmedArticleSet>
  <PubmedArticle>
    <MedlineCitation Status=\"MEDLINE\" Owner=\"NLM\">
      <PMID Version=\"1\">33397721</PMID>
      <DateCompleted>
        <Year>2021</Year>
        <Month>05</Month>
        <Day>10</Day>
      </DateCompleted>
      <DateRevised>
        <Year>2021</Year>
        <Month>07</Month>
        <Day>05</Day>
      </DateRevised>
      <Article PubModel=\"Print\">
        <Journal>
          <ISSN IssnType=\"Electronic\">1091-6490</ISSN>
          <JournalIssue CitedMedium=\"Internet\">
            <Volume>118</Volume>
            <Issue>2</Issue>
            <PubDate>
              <Year>2021</Year>
              <Month>Jan</Month>
              <Day>12</Day>
            </PubDate>
          </JournalIssue>
          <Title>Proceedings of the National Academy of Sciences of the United States of America</Title>
          <ISOAbbreviation>Proc Natl Acad Sci U S A</ISOAbbreviation>
        </Journal>
        <ArticleTitle>Small-molecule inhibitors for the Prp8 intein as antifungal agents.</ArticleTitle>
        <ELocationID EIdType=\"pii\" ValidYN=\"Y\">e2008815118</ELocationID>
        <ELocationID EIdType=\"doi\" ValidYN=\"Y\">10.1073/pnas.2008815118</ELocationID>
        <Abstract>
          <AbstractText>Self-splicing proteins, called inteins, are present in many human pathogens,
            including the emerging fungal threats <i>Cryptococcus neoformans</i> (<i>Cne</i>) and <i>Cryptococcus
            gattii</i> (<i>Cga</i>), the causative agents of cryptococcosis. Inhibition of protein
            splicing in <i>Cryptococcus</i> sp. interferes with activity of the only
            intein-containing protein, Prp8, an essential intron splicing factor. Here, we screened
            a small-molecule library to find addititonal, potent inhibitors of the <i>Cne</i> Prp8
            intein using a split-GFP splicing assay. This revealed the compound 6G-318S, with IC<sub>
            50</sub> values in the low micromolar range in the split-GFP assay and in a
            complementary split-luciferase system. A fluoride derivative of the compound 6G-318S
            displayed improved cytotoxicity in human lung carcinoma cells, although there was a
            slight reduction in the inhibition of splicing. 6G-318S and its derivative inhibited
            splicing of the <i>Cne</i> Prp8 intein in vivo in <i>Escherichia coli</i> and in <i>C.
            neoformans</i> Moreover, the compounds repressed growth of WT <i>C. neoformans</i> and <i>C.
            gattii</i> In contrast, the inhibitors were less potent at inhibiting growth of the
            inteinless <i>Candida albicans</i> Drug resistance was observed when the Prp8 intein was
            overexpressed in <i>C. neoformans</i>, indicating specificity of this molecule toward
            the target. No off-target activity was observed, such as inhibition of serine/cysteine
            proteases. The inhibitors bound covalently to the Prp8 intein and binding was reduced
            when the active-site residue Cys1 was mutated. 6G-318S showed a synergistic effect with
            amphotericin B and additive to indifferent effects with a few other clinically used
            antimycotics. Overall, the identification of these small-molecule intein-splicing
            inhibitors opens up prospects for a new class of antifungals.</AbstractText>
        </Abstract>
        <AuthorList CompleteYN=\"Y\">
          <Author ValidYN=\"Y\">
            <LastName>Li</LastName>
            <ForeName>Zhong</ForeName>
            <Initials>Z</Initials>
            <AffiliationInfo>
              <Affiliation>Wadsworth Center, New York State Department of Health, Albany, NY 12208.</Affiliation>
            </AffiliationInfo>
          </Author>
          <Author ValidYN=\"Y\">
            <LastName>Tharappel</LastName>
            <ForeName>Anil Mathew</ForeName>
            <Initials>AM</Initials>
            <AffiliationInfo>
              <Affiliation>Wadsworth Center, New York State Department of Health, Albany, NY 12208.</Affiliation>
            </AffiliationInfo>
          </Author>
          <Author ValidYN=\"Y\">
            <LastName>Xu</LastName>
            <ForeName>Jimin</ForeName>
            <Initials>J</Initials>
            <Identifier Source=\"ORCID\">0000-0001-8245-7263</Identifier>
            <AffiliationInfo>
              <Affiliation>Chemical Biology Program, Department of Pharmacology and Toxicology,
                University of Texas Medical Branch, Galveston, TX 77555.</Affiliation>
            </AffiliationInfo>
          </Author>
          <Author ValidYN=\"Y\">
            <LastName>Lang</LastName>
            <ForeName>Yuekun</ForeName>
            <Initials>Y</Initials>
            <AffiliationInfo>
              <Affiliation>Wadsworth Center, New York State Department of Health, Albany, NY 12208.</Affiliation>
            </AffiliationInfo>
          </Author>
          <Author ValidYN=\"Y\">
            <LastName>Green</LastName>
            <ForeName>Cathleen M</ForeName>
            <Initials>CM</Initials>
            <AffiliationInfo>
              <Affiliation>Department of Biological Sciences and RNA Institute, University at
                Albany, Albany, NY 12222.</Affiliation>
            </AffiliationInfo>
          </Author>
          <Author ValidYN=\"Y\">
            <LastName>Zhang</LastName>
            <ForeName>Jing</ForeName>
            <Initials>J</Initials>
            <AffiliationInfo>
              <Affiliation>Wadsworth Center, New York State Department of Health, Albany, NY 12208.</Affiliation>
            </AffiliationInfo>
          </Author>
          <Author ValidYN=\"Y\">
            <LastName>Lin</LastName>
            <ForeName>Qishan</ForeName>
            <Initials>Q</Initials>
            <Identifier Source=\"ORCID\">0000-0002-1756-1432</Identifier>
            <AffiliationInfo>
              <Affiliation>RNA Epitranscriptomics &amp; Proteomics Resource, University at Albany,
                Albany, NY 12222.</Affiliation>
            </AffiliationInfo>
          </Author>
          <Author ValidYN=\"Y\">
            <LastName>Chaturvedi</LastName>
            <ForeName>Sudha</ForeName>
            <Initials>S</Initials>
            <Identifier Source=\"ORCID\">0000-0003-0906-8426</Identifier>
            <AffiliationInfo>
              <Affiliation>Wadsworth Center, New York State Department of Health, Albany, NY 12208.</Affiliation>
            </AffiliationInfo>
            <AffiliationInfo>
              <Affiliation>Department of Biomedical Sciences, School of Public Health, University at
                Albany, Albany, NY 12201-0509.</Affiliation>
            </AffiliationInfo>
          </Author>
          <Author ValidYN=\"Y\">
            <LastName>Zhou</LastName>
            <ForeName>Jia</ForeName>
            <Initials>J</Initials>
            <Identifier Source=\"ORCID\">0000-0002-2811-1090</Identifier>
            <AffiliationInfo>
              <Affiliation>Chemical Biology Program, Department of Pharmacology and Toxicology,
                University of Texas Medical Branch, Galveston, TX 77555.</Affiliation>
            </AffiliationInfo>
          </Author>
          <Author ValidYN=\"Y\">
            <LastName>Belfort</LastName>
            <ForeName>Marlene</ForeName>
            <Initials>M</Initials>
            <AffiliationInfo>
              <Affiliation>Department of Biological Sciences and RNA Institute, University at
                Albany, Albany, NY 12222; mbelfort@albany.edu hli1@pharmacy.arizona.edu.</Affiliation>
            </AffiliationInfo>
            <AffiliationInfo>
              <Affiliation>Department of Biomedical Sciences, School of Public Health, University at
                Albany, Albany, NY 12201-0509.</Affiliation>
            </AffiliationInfo>
          </Author>
          <Author ValidYN=\"Y\">
            <LastName>Li</LastName>
            <ForeName>Hongmin</ForeName>
            <Initials>H</Initials>
            <AffiliationInfo>
              <Affiliation>Wadsworth Center, New York State Department of Health, Albany, NY 12208;
                mbelfort@albany.edu hli1@pharmacy.arizona.edu.</Affiliation>
            </AffiliationInfo>
            <AffiliationInfo>
              <Affiliation>Department of Biomedical Sciences, School of Public Health, University at
                Albany, Albany, NY 12201-0509.</Affiliation>
            </AffiliationInfo>
            <AffiliationInfo>
              <Affiliation>Department of Pharmacology and Toxicology, College of Pharmacy,
                University of Arizona, Tucson, AZ 85721.</Affiliation>
            </AffiliationInfo>
          </Author>
        </AuthorList>
        <Language>eng</Language>
        <GrantList CompleteYN=\"Y\">
          <Grant>
            <GrantID>R01 AI140726</GrantID>
            <Acronym>AI</Acronym>
            <Agency>NIAID NIH HHS</Agency>
            <Country>United States</Country>
          </Grant>
          <Grant>
            <GrantID>R01 GM044844</GrantID>
            <Acronym>GM</Acronym>
            <Agency>NIGMS NIH HHS</Agency>
            <Country>United States</Country>
          </Grant>
          <Grant>
            <GrantID>R21 AI141178</GrantID>
            <Acronym>AI</Acronym>
            <Agency>NIAID NIH HHS</Agency>
            <Country>United States</Country>
          </Grant>
        </GrantList>
        <PublicationTypeList>
          <PublicationType UI=\"D016428\">Journal Article</PublicationType>
          <PublicationType UI=\"D052061\">Research Support, N.I.H., Extramural</PublicationType>
          <PublicationType UI=\"D013485\">Research Support, Non-U.S. Gov't</PublicationType>
        </PublicationTypeList>
      </Article>
      <MedlineJournalInfo>
        <Country>United States</Country>
        <MedlineTA>Proc Natl Acad Sci U S A</MedlineTA>
        <NlmUniqueID>7505876</NlmUniqueID>
        <ISSNLinking>0027-8424</ISSNLinking>
      </MedlineJournalInfo>
      <ChemicalList>
        <Chemical>
          <RegistryNumber>0</RegistryNumber>
          <NameOfSubstance UI=\"D000935\">Antifungal Agents</NameOfSubstance>
        </Chemical>
        <Chemical>
          <RegistryNumber>0</RegistryNumber>
          <NameOfSubstance UI=\"D005656\">Fungal Proteins</NameOfSubstance>
        </Chemical>
        <Chemical>
          <RegistryNumber>0</RegistryNumber>
          <NameOfSubstance UI=\"C115374\">PRPF8 protein, human</NameOfSubstance>
        </Chemical>
        <Chemical>
          <RegistryNumber>0</RegistryNumber>
          <NameOfSubstance UI=\"D016601\">RNA-Binding Proteins</NameOfSubstance>
        </Chemical>
      </ChemicalList>
      <CitationSubset>IM</CitationSubset>
      <MeshHeadingList>
        <MeshHeading>
          <DescriptorName UI=\"D000935\" MajorTopicYN=\"N\">Antifungal Agents</DescriptorName>
          <QualifierName UI=\"Q000494\" MajorTopicYN=\"N\">pharmacology</QualifierName>
        </MeshHeading>
        <MeshHeading>
          <DescriptorName UI=\"D003455\" MajorTopicYN=\"N\">Cryptococcus neoformans</DescriptorName>
          <QualifierName UI=\"Q000235\" MajorTopicYN=\"N\">genetics</QualifierName>
          <QualifierName UI=\"Q000378\" MajorTopicYN=\"N\">metabolism</QualifierName>
          <QualifierName UI=\"Q000472\" MajorTopicYN=\"N\">pathogenicity</QualifierName>
        </MeshHeading>
        <MeshHeading>
          <DescriptorName UI=\"D005656\" MajorTopicYN=\"N\">Fungal Proteins</DescriptorName>
          <QualifierName UI=\"Q000378\" MajorTopicYN=\"N\">metabolism</QualifierName>
        </MeshHeading>
        <MeshHeading>
          <DescriptorName UI=\"D006801\" MajorTopicYN=\"N\">Humans</DescriptorName>
        </MeshHeading>
        <MeshHeading>
          <DescriptorName UI=\"D047668\" MajorTopicYN=\"N\">Inteins</DescriptorName>
          <QualifierName UI=\"Q000235\" MajorTopicYN=\"N\">genetics</QualifierName>
        </MeshHeading>
        <MeshHeading>
          <DescriptorName UI=\"D007438\" MajorTopicYN=\"N\">Introns</DescriptorName>
          <QualifierName UI=\"Q000235\" MajorTopicYN=\"N\">genetics</QualifierName>
        </MeshHeading>
        <MeshHeading>
          <DescriptorName UI=\"D019154\" MajorTopicYN=\"N\">Protein Splicing</DescriptorName>
          <QualifierName UI=\"Q000235\" MajorTopicYN=\"N\">genetics</QualifierName>
          <QualifierName UI=\"Q000502\" MajorTopicYN=\"Y\">physiology</QualifierName>
        </MeshHeading>
        <MeshHeading>
          <DescriptorName UI=\"D012326\" MajorTopicYN=\"N\">RNA Splicing</DescriptorName>
          <QualifierName UI=\"Q000235\" MajorTopicYN=\"N\">genetics</QualifierName>
        </MeshHeading>
        <MeshHeading>
          <DescriptorName UI=\"D016601\" MajorTopicYN=\"N\">RNA-Binding Proteins</DescriptorName>
          <QualifierName UI=\"Q000235\" MajorTopicYN=\"Y\">genetics</QualifierName>
          <QualifierName UI=\"Q000378\" MajorTopicYN=\"N\">metabolism</QualifierName>
        </MeshHeading>
        <MeshHeading>
          <DescriptorName UI=\"D016415\" MajorTopicYN=\"N\">Sequence Alignment</DescriptorName>
          <QualifierName UI=\"Q000379\" MajorTopicYN=\"N\">methods</QualifierName>
        </MeshHeading>
      </MeshHeadingList>
      <KeywordList Owner=\"NOTNLM\">
        <Keyword MajorTopicYN=\"N\">Cryptococcus</Keyword>
        <Keyword MajorTopicYN=\"N\">Prp8 intein</Keyword>
        <Keyword MajorTopicYN=\"N\">antifungal</Keyword>
        <Keyword MajorTopicYN=\"N\">protein splicing</Keyword>
        <Keyword MajorTopicYN=\"N\">small-molecule inhibitor</Keyword>
      </KeywordList>
      <CoiStatement>The authors declare no competing interest.</CoiStatement>
    </MedlineCitation>
    <PubmedData>
      <History>
        <PubMedPubDate PubStatus=\"entrez\">
          <Year>2021</Year>
          <Month>1</Month>
          <Day>5</Day>
          <Hour>6</Hour>
          <Minute>14</Minute>
        </PubMedPubDate>
        <PubMedPubDate PubStatus=\"pubmed\">
          <Year>2021</Year>
          <Month>1</Month>
          <Day>6</Day>
          <Hour>6</Hour>
          <Minute>0</Minute>
        </PubMedPubDate>
        <PubMedPubDate PubStatus=\"medline\">
          <Year>2021</Year>
          <Month>5</Month>
          <Day>11</Day>
          <Hour>6</Hour>
          <Minute>0</Minute>
        </PubMedPubDate>
        <PubMedPubDate PubStatus=\"pmc-release\">
          <Year>2021</Year>
          <Month>7</Month>
          <Day>4</Day>
        </PubMedPubDate>
      </History>
      <PublicationStatus>ppublish</PublicationStatus>
      <ArticleIdList>
        <ArticleId IdType=\"pubmed\">33397721</ArticleId>
        <ArticleId IdType=\"pmc\">PMC7812778</ArticleId>
        <ArticleId IdType=\"doi\">10.1073/pnas.2008815118</ArticleId>
        <ArticleId IdType=\"pii\">2008815118</ArticleId>
      </ArticleIdList>
      <ReferenceList>
        <Reference>
          <Citation>Mills K. V., Johnson M. A., Perler F. B., Protein splicing: How inteins escape
            from precursor proteins. J. Biol. Chem. 289, 14498&#x2013;14505 (2014).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC4031507</ArticleId>
            <ArticleId IdType=\"pubmed\">24695729</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Aranko A. S., Wlodawer A., Iwa&#xef; H., Nature&#x2019;s recipe for splitting
            inteins. Protein Eng. Des. Sel. 27, 263&#x2013;271 (2014).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC4133565</ArticleId>
            <ArticleId IdType=\"pubmed\">25096198</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Eryilmaz E., Shah N. H., Muir T. W., Cowburn D., Structural and dynamical
            features of inteins and implications on protein splicing. J. Biol. Chem. 289,
            14506&#x2013;14511 (2014).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC4031508</ArticleId>
            <ArticleId IdType=\"pubmed\">24695731</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Novikova O., Topilina N., Belfort M., Enigmatic distribution, evolution, and
            function of inteins. J. Biol. Chem. 289, 14490&#x2013;14497 (2014).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC4031506</ArticleId>
            <ArticleId IdType=\"pubmed\">24695741</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Novikova O., et al. , Intein clustering suggests functional importance in
            different domains of life. Mol. Biol. Evol. 33, 783&#x2013;799 (2016).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC4760082</ArticleId>
            <ArticleId IdType=\"pubmed\">26609079</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>CDC , Basic TB Facts, https://www.cdc.gov/tb/topic/basics/default.htm. Accessed
            20 March 2016.</Citation>
        </Reference>
        <Reference>
          <Citation>Green C. M., et al. , Spliceosomal Prp8 intein at the crossroads of protein and
            RNA splicing. PLoS Biol. 17, e3000104 (2019).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC6805012</ArticleId>
            <ArticleId IdType=\"pubmed\">31600193</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Li Z., et al. , Cisplatin protects mice from challenge of Cryptococcus
            neoformans by targeting the Prp8 intein. Emerg. Microbes Infect. 8, 895&#x2013;908
            (2019).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC6598491</ArticleId>
            <ArticleId IdType=\"pubmed\">31223062</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Perfect J. R., Fungal diagnosis: How do we do it and can we do better? Curr.
            Med. Res. Opin. 29 (suppl. 4), 3&#x2013;11 (2013).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pubmed\">23621588</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Brown G. D., et al. , Hidden killers: Human fungal infections. Sci. Transl. Med.
            4, 165rv113 (2012).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pubmed\">23253612</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Gullo A., Invasive fungal infections: The challenge continues. Drugs 69 (suppl.
            1), 65&#x2013;73 (2009).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pubmed\">19877737</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Tuite N. L., Lacey K., Overview of invasive fungal infections. Methods Mol.
            Biol. 968, 1&#x2013;23 (2013).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pubmed\">23296882</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Gandhi N. R., et al. , Extensively drug-resistant tuberculosis as a cause of
            death in patients co-infected with tuberculosis and HIV in a rural area of South Africa.
            Lancet 368, 1575&#x2013;1580 (2006).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pubmed\">17084757</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>WHO , Management of MDR-TB: A Field Guide: A Companion Document to Guidelines
            for Programmatic Management of Drug-Resistant Tuberculosis: Integrated Management of
            Adolescent and Adult Illness (IMAI) (World Health Organization, 2009).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pubmed\">26290923</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Nathan C., Taming tuberculosis: A challenge for science and society. Cell Host
            Microbe 5, 220&#x2013;224 (2009).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pubmed\">19286131</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Pfaller M. A., Antifungal drug resistance: Mechanisms, epidemiology, and
            consequences for treatment. Am. J. Med. 125(suppl. 1)S3&#x2013;S13 (2012).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pubmed\">22196207</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Ghannoum M. A., Rice L. B., Antifungal agents: Mode of action, mechanisms of
            resistance, and correlation of these mechanisms with bacterial resistance. Clin.
            Microbiol. Rev. 12, 501&#x2013;517 (1999).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC88922</ArticleId>
            <ArticleId IdType=\"pubmed\">10515900</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Howard S. J., et al. , Frequency and evolution of Azole resistance in
            Aspergillus fumigatus associated with treatment failure. Emerg. Infect. Dis. 15,
            1068&#x2013;1076 (2009).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC2744247</ArticleId>
            <ArticleId IdType=\"pubmed\">19624922</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Paulus H., Protein splicing inhibitors as a new class of antimycobacterial
            agents. Drugs Future 32, 973&#x2013;984 (2007).</Citation>
        </Reference>
        <Reference>
          <Citation>Zhang L., Zheng Y., Callahan B., Belfort M., Liu Y., Cisplatin inhibits protein
            splicing, suggesting inteins as therapeutic targets in mycobacteria. J. Biol. Chem. 286,
            1277&#x2013;1282 (2011).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC3020735</ArticleId>
            <ArticleId IdType=\"pubmed\">21059649</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Chan H., et al. , Exploring intein inhibition by platinum compounds as an
            antimicrobial strategy. J. Biol. Chem. 291, 22661&#x2013;22670 (2016).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC5077202</ArticleId>
            <ArticleId IdType=\"pubmed\">27609519</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Manohar S., Leung N., Cisplatin nephrotoxicity: A review of the literature. J.
            Nephrol. 31, 15&#x2013;25 (2018).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pubmed\">28382507</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Barabas K., Milner R., Lurie D., Adin C., Cisplatin: A review of toxicities and
            therapeutic applications. Vet. Comp. Oncol. 6, 1&#x2013;18 (2008).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pubmed\">19178659</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Paken J., Govender C. D., Pillay M., Sewram V., Cisplatin-associated
            ototoxicity: A review for the health professional. J. Toxicol. 2016, 1809394 (2016).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC5223030</ArticleId>
            <ArticleId IdType=\"pubmed\">28115933</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Gangopadhyay J. P., Jiang S. Q., Paulus H., An in vitro screening system for
            protein splicing inhibitors based on green fluorescent protein as an indicator. Anal.
            Chem. 75, 2456&#x2013;2462 (2003).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pubmed\">12918990</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Brecher M., et al. , A conformational switch high-throughput screening assay and
            allosteric inhibition of the flavivirus NS2B-NS3 protease. PLoS Pathog. 13, e1006411
            (2017).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC5462475</ArticleId>
            <ArticleId IdType=\"pubmed\">28542603</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Iversen P. W., et al. , &#x201c;HTS assay validation&#x201d; in Assay Guidance
            Manual, Markossian S., Eds. (Eli Lilly and Company and the National Center for Advancing
            Translational Sciences, 2004).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pubmed\">22553862</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Owen T. S., et al. , F&#xf6;rster resonance energy transfer-based
            cholesterolysis assay identifies a novel hedgehog inhibitor. Anal. Biochem. 488,
            1&#x2013;5 (2015).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC4591182</ArticleId>
            <ArticleId IdType=\"pubmed\">26095399</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Li Z., et al. , Existing drugs as broad-spectrum and potent inhibitors for Zika
            virus by targeting NS2B-NS3 interaction. Cell Res. 27, 1046&#x2013;1064 (2017).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC5539352</ArticleId>
            <ArticleId IdType=\"pubmed\">28685770</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Li Z., et al. , Erythrosin B is a potent and broad-spectrum orthosteric
            inhibitor of the flavivirus NS2B-NS3 protease. Antiviral Res. 150, 217&#x2013;225
            (2018).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC5892443</ArticleId>
            <ArticleId IdType=\"pubmed\">29288700</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Suda H., Aoyagi T., Hamada M., Takeuchi T., Umezawa H., Antipain, a new protease
            inhibitor isolated from actinomycetes. J. Antibiot. (Tokyo) 25, 263&#x2013;266 (1972).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pubmed\">4559651</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Rex J. H., et al. , Reference Method for Broth Dilution Antifungal
            Susceptibility Testing of Yeasts (Cold Spring Harbor Laboratory, ed. 3, 2008).</Citation>
        </Reference>
        <Reference>
          <Citation>Archibald L. K., et al. , Antifungal susceptibilities of Cryptococcus
            neoformans. Emerg. Infect. Dis. 10, 143&#x2013;145 (2004).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC3322769</ArticleId>
            <ArticleId IdType=\"pubmed\">15078612</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Hazen K. C., Fungicidal versus fungistatic activity of terbinafine and
            itraconazole: An in vitro comparison. J. Am. Acad. Dermatol. 38, S37&#x2013;S41 (1998).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pubmed\">9594935</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Fothergill A. W., &#x201c;Antifungal susceptibility testing: Clinical laboratory
            and standard institute (CLSI) methods&#x201d; in Interactions of Yeasts, Moulds and
            Antifungal Agents: How to Detect resistance, Hall G. S., Ed. (Human Press, New York,
            2012), pp. 65&#x2013;75.</Citation>
        </Reference>
        <Reference>
          <Citation>Hai T. P., et al. , The combination of tamoxifen with amphotericin B, but not
            with fluconazole, has synergistic activity against the majority of clinical isolates of
            Cryptococcus neoformans. Mycoses 62, 818&#x2013;825 (2019).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC6771715</ArticleId>
            <ArticleId IdType=\"pubmed\">31173410</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Lewis R. E., Diekema D. J., Messer S. A., Pfaller M. A., Klepser M. E.,
            Comparison of Etest, chequerboard dilution and time-kill studies for the detection of
            synergy or antagonism between antifungal agents tested against Candida species. J.
            Antimicrob. Chemother. 49, 345&#x2013;351 (2002).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pubmed\">11815578</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Doern C. D., When does 2 plus 2 equal 5? A review of antimicrobial synergy
            testing. J. Clin. Microbiol. 52, 4124&#x2013;4128 (2014).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC4313275</ArticleId>
            <ArticleId IdType=\"pubmed\">24920779</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Liu Z., et al. , Structure of the branched intermediate in protein splicing.
            Proc. Natl. Acad. Sci. U.S.A. 111, 8422&#x2013;8427 (2014).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC4060664</ArticleId>
            <ArticleId IdType=\"pubmed\">24778214</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Perfect J. R., Bicanic T., Cryptococcosis diagnosis and treatment: What do we
            know now. Fungal Genet. Biol. 78, 49&#x2013;54 (2015).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC4395512</ArticleId>
            <ArticleId IdType=\"pubmed\">25312862</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Chen Y., et al. , The Cryptococcus neoformans transcriptome at the site of human
            meningitis. MBio 5, e01087&#x2013;e13 (2014).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC3950508</ArticleId>
            <ArticleId IdType=\"pubmed\">24496797</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Zhai B., Wu C., Wang L., Sachs M. S., Lin X., The antidepressant sertraline
            provides a promising therapeutic option for neurotropic cryptococcal infections.
            Antimicrob. Agents Chemother. 56, 3758&#x2013;3766 (2012).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC3393448</ArticleId>
            <ArticleId IdType=\"pubmed\">22508310</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Brouwer A. E., et al. , Combination antifungal therapies for HIV-associated
            cryptococcal meningitis: A randomised trial. Lancet 363, 1764&#x2013;1767 (2004).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pubmed\">15172774</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Husain S., Wagener M. M., Singh N., Cryptococcus neoformans infection in organ
            transplant recipients: Variables influencing clinical characteristics and outcome.
            Emerg. Infect. Dis. 7, 375&#x2013;381 (2001).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC2631789</ArticleId>
            <ArticleId IdType=\"pubmed\">11384512</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>MacDougall L., et al. , Spread of Cryptococcus gattii in British Columbia,
            Canada, and detection in the pacific northwest, USA. Emerg. Infect. Dis. 13,
            42&#x2013;50 (2007).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC2725832</ArticleId>
            <ArticleId IdType=\"pubmed\">17370514</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Fyfe M., et al. , Cryptococcus gattii infections on Vancouver Island, British
            Columbia, Canada: Emergence of a tropical fungus in a temperate environment. Can.
            Commun. Dis. Rep. 34, 1&#x2013;12 (2008).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pubmed\">18802986</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Kronstad J. W., et al. , Expanding fungal pathogenesis: Cryptococcus breaks out
            of the opportunistic box. Nat. Rev. Microbiol. 9, 193&#x2013;203 (2011).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC4698337</ArticleId>
            <ArticleId IdType=\"pubmed\">21326274</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Bartlett K. H., et al. , A decade of experience: Cryptococcus gattii in British
            Columbia. Mycopathologia 173, 311&#x2013;319 (2012).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pubmed\">21960040</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Bartlett K. H., Kidd S. E., Kronstad J. W., The emergence of Cryptococcus gattii
            in British Columbia and the Pacific Northwest. Curr. Infect. Dis. Rep. 10, 58&#x2013;65
            (2008).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pubmed\">18377817</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Upton A., et al. , First contemporary case of human infection with Cryptococcus
            gattii in Puget Sound: Evidence for spread of the Vancouver Island outbreak. J. Clin.
            Microbiol. 45, 3086&#x2013;3088 (2007).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC2045307</ArticleId>
            <ArticleId IdType=\"pubmed\">17596366</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Byrnes E. J., 3rd, et al. , A diverse population of Cryptococcus gattii
            molecular type VGIII in southern Californian HIV/AIDS patients. PLoS Pathog. 7, e1002205
            (2011).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC3164645</ArticleId>
            <ArticleId IdType=\"pubmed\">21909264</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Byrnes E. J. 3rd, Bartlett K. H., Perfect J. R., Heitman J., Cryptococcus
            gattii: An emerging fungal pathogen infecting humans and animals. Microbes Infect. 13,
            895&#x2013;907 (2011).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC3318971</ArticleId>
            <ArticleId IdType=\"pubmed\">21684347</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Byrnes E. J., 3rd, et al. , Emergence and pathogenicity of highly virulent
            Cryptococcus gattii genotypes in the northwest United States. PLoS Pathog. 6, e1000850
            (2010).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC2858702</ArticleId>
            <ArticleId IdType=\"pubmed\">20421942</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Byrnes E. J., Heitman J., Cryptococcus gattii outbreak expands into the
            Northwestern United States with fatal consequences. F1000 Biol. Rep. 1, 62 (2009).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC2818080</ArticleId>
            <ArticleId IdType=\"pubmed\">20150950</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Datta K. et al. .; Cryptococcus gattii Working Group of the Pacific Northwest ,
            Spread of Cryptococcus gattii into Pacific Northwest region of the United States. Emerg.
            Infect. Dis. 15, 1185&#x2013;1191 (2009).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC2815957</ArticleId>
            <ArticleId IdType=\"pubmed\">19757550</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Byrnes E. J., 3rd, et al. , First reported case of Cryptococcus gattii in the
            southeastern USA: Implications for travel-associated acquisition of an emerging
            pathogen. PLoS One 4, e5851 (2009).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC2689935</ArticleId>
            <ArticleId IdType=\"pubmed\">19516904</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Perfect J. R., et al. , Clinical practice guidelines for the management of
            cryptococcal disease: 2010 update by the Infectious Diseases Society of America. Clin.
            Infect. Dis. 50, 291&#x2013;322 (2010).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC5826644</ArticleId>
            <ArticleId IdType=\"pubmed\">20047480</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Boulware D. R. et al. .; COAT Trial Team , Timing of antiretroviral therapy
            after diagnosis of cryptococcal meningitis. N. Engl. J. Med. 370, 2487&#x2013;2498
            (2014).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC4127879</ArticleId>
            <ArticleId IdType=\"pubmed\">24963568</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Rajasingham R., Rolfes M. A., Birkenkamp K. E., Meya D. B., Boulware D. R.,
            Cryptococcal meningitis treatment strategies in resource-limited settings: A
            cost-effectiveness analysis. PLoS Med. 9, e1001316 (2012).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC3463510</ArticleId>
            <ArticleId IdType=\"pubmed\">23055838</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Perea S., Patterson T. F., Antifungal resistance in pathogenic fungi. Clin.
            Infect. Dis. 35, 1073&#x2013;1080 (2002).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pubmed\">12384841</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Zuger A., Louie E., Holzman R. S., Simberkoff M. S., Rahal J. J., Cryptococcal
            disease in patients with the acquired immunodeficiency syndrome. Diagnostic features and
            outcome of treatment. Ann. Intern. Med. 104, 234&#x2013;240 (1986).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pubmed\">3946951</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Boelaert J. R., Goddeeris K. H., Vanopdenbosch L. J., Casselman J. W., Relapsing
            meningitis caused by persistent cryptococcal antigens and immune reconstitution after
            the initiation of highly active antiretroviral therapy. AIDS 18, 1223&#x2013;1224
            (2004).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pubmed\">15166545</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Cornely O. A. et al. .; AmBiLoad Trial Study Group , Liposomal amphotericin B as
            initial therapy for invasive mold infection: A randomized trial comparing a high-loading
            dose regimen with standard dosing (AmBiLoad trial). Clin. Infect. Dis. 44,
            1289&#x2013;1297 (2007).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pubmed\">17443465</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Schiller D. S., Fung H. B., Posaconazole: An extended-spectrum triazole
            antifungal agent. Clin. Ther. 29, 1862&#x2013;1886 (2007).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pubmed\">18035188</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Baginski M., Czub J., Amphotericin B and its new derivatives&#x2014;Mode of
            action. Curr. Drug Metab. 10, 459&#x2013;469 (2009).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pubmed\">19689243</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Gray K. C., et al. , Amphotericin primarily kills yeast by simply binding
            ergosterol. Proc. Natl. Acad. Sci. U.S.A. 109, 2234&#x2013;2239 (2012).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC3289339</ArticleId>
            <ArticleId IdType=\"pubmed\">22308411</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Hitchcock C. A., Dickinson K., Brown S. B., Evans E. G., Adams D. J.,
            Interaction of azole antifungal antibiotics with cytochrome P-450-dependent 14
            alpha-sterol demethylase purified from Candida albicans. Biochem. J. 266, 475&#x2013;480
            (1990).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC1131156</ArticleId>
            <ArticleId IdType=\"pubmed\">2180400</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Polak A., Scholer H. J., Mode of action of 5-fluorocytosine and mechanisms of
            resistance. Chemotherapy 21, 113&#x2013;130 (1975).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pubmed\">1098864</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Deresinski S. C., Stevens D. A., Caspofungin. Clin. Infect. Dis. 36,
            1445&#x2013;1457 (2003).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pubmed\">12766841</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Chen S. C., Slavin M. A., Sorrell T. C., Echinocandin antifungal drugs in fungal
            infections: A comparison. Drugs 71, 11&#x2013;41 (2011).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pubmed\">21175238</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Kartsonis N. A., Nielsen J., Douglas C. M., Caspofungin: The first in a new
            class of antifungal agents. Drug Resist. Updat. 6, 197&#x2013;218 (2003).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pubmed\">12962685</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Maligie M. A., Selitrennikoff C. P., Cryptococcus neoformans resistance to
            echinocandins: (1,3)beta-glucan synthase activity is sensitive to echinocandins.
            Antimicrob. Agents Chemother. 49, 2851&#x2013;2856 (2005).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC1168702</ArticleId>
            <ArticleId IdType=\"pubmed\">15980360</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Dupont B., Pialoux G., Amphotericin versus fluconazole in cryptococcal
            meningitis. N. Engl. J. Med. 326, 1568, author reply 1568&#x2013;1569 (1992).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pubmed\">1579145</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Gubbins P. O., McConnell S. A., Penzak S. R., Drug Interactions in Infectious
            Diseases (Humana Press, Totowa, NJ, 2001).</Citation>
        </Reference>
        <Reference>
          <Citation>Moen M. D., Lyseng-Williamson K. A., Scott L. J., Liposomal amphotericin B: A
            review of its use as empirical therapy in febrile neutropenia and in the treatment of
            invasive fungal infections. Drugs 69, 361&#x2013;392 (2009).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pubmed\">19275278</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Kauffman C. A., Fungal infections. Proc. Am. Thorac. Soc. 3, 35&#x2013;40
            (2006).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pubmed\">16493149</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Butler M. I., Goodwin T. J., Poulter R. T., A nuclear-encoded intein in the
            fungal pathogen Cryptococcus neoformans. Yeast 18, 1365&#x2013;1370 (2001).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pubmed\">11746598</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Butler M. I., Poulter R. T., The PRP8 inteins in Cryptococcus are a source of
            phylogenetic and epidemiological information. Fungal Genet. Biol. 42, 452&#x2013;463
            (2005).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pubmed\">15809009</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Liu X. Q., Yang J., Prp8 intein in fungal pathogens: Target for potential
            antifungal drugs. FEBS Lett. 572, 46&#x2013;50 (2004).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pubmed\">15304322</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Pearl E. J., Tyndall J. D., Poulter R. T., Wilbanks S. M., Sequence requirements
            for splicing by the Cne PRP8 intein. FEBS Lett. 581, 3000&#x2013;3004 (2007).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pubmed\">17544410</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Chen H., et al. , Selective inhibition of the West Nile virus methyltransferase
            by nucleoside analogs. Antiviral Res. 97, 232&#x2013;239 (2013).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC3608738</ArticleId>
            <ArticleId IdType=\"pubmed\">23267828</ArticleId>
          </ArticleIdList>
        </Reference>
        <Reference>
          <Citation>Brecher M., et al. , Identification and Characterization of novel broad-spectrum
            inhibitors of the flavivirus methyltransferase. ACS Infect. Dis. 1, 340&#x2013;349
            (2015).</Citation>
          <ArticleIdList>
            <ArticleId IdType=\"pmc\">PMC4696607</ArticleId>
            <ArticleId IdType=\"pubmed\">26726314</ArticleId>
          </ArticleIdList>
        </Reference>
      </ReferenceList>
    </PubmedData>
  </PubmedArticle>
</PubmedArticleSet>
"
